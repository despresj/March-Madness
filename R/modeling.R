library(tidymodels)
theme_set(theme_test())
source(here::here("R", "bracket.R"))
source(here::here("R", 'cleaningScript.R'))

# merged <- readr::read_csv(here::here("data", "merged.csv"))

# Take a look -------------------------------------------------------------


# model selection ---------------------------------------------------------

fit <- glm(win ~ x3fg +
         opposingx3fg +
# field goal pct
           fg_percent +
   opposingfg_percent +
# free throws
           ft_percent +
   opposingft_percent +
# rebound per game
                  rpg + 
          opposingrpg +
# steels
                   st +
           opposingst +
#turnover
                   to +
           opposingto +
# blocks
         opposingbkpg +
                 bkpg,
           data = merged, family = "binomial")
summary(fit)

s2021 <- team_stats %>% 
  filter(season == 2021, 
         TeamID %in% c(bracket$teamid, bracket$otherteamid)) %>% 
  distinct(TeamID, .keep_all = TRUE) %>% 
  select(-season) 

s2021

predictor_fn <- function (team_1_id, team_2_id) {
  stats_team_1 <- filter(s2021, TeamID == team_1_id)
  stats_team_2 <- filter(s2021, TeamID == team_2_id) %>% 
  rename_all(~ paste0("opposing",.)) 
  bound_cols <- bind_cols(stats_team_1, stats_team_2)
  pred <- predict(fit, newdata = bound_cols, type = "response")
  return(pred)
}

possibly_predictor_fn <- possibly(.f = predictor_fn, otherwise = 0)

# app state is missing from the data
# that 0 puts a zero pros of them winning to effectively drop them.

probs <- map2_dbl(.x = bracket$teamid, 
                  .y = bracket$otherteamid, 
                  .f = possibly_predictor_fn)

bracket <- bracket %>% 
  mutate(team_prob = probs,
         otherteam_prob = 1 - team_prob, 
         game = paste0(team, " vs. ", otherteam),
         predicted_winner = if_else(team_prob > 0.5, team, otherteam),
         predicted_winnerid = if_else(team_prob > 0.5, teamid, otherteamid))
  
games <- bracket %>% 
  mutate(team_prob = as.numeric(probs),
         otherteam_prob = 1 - team_prob, 
         game = paste0(team, " vs. ", otherteam)) %>% 
  select(game, team_prob, otherteam_prob)

games
