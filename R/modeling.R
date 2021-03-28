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
  distinct(TeamID,.keep_all = TRUE ) %>% 
  select(-season) %>% 
  select(
    team,
    TeamID,
    x3fg,
    fg_percent,
    ft_percent,
    rpg,
    st,
    to,
    bkpg)

s2021

predictor_fn <- function (team_1_id, team_2_id) {
  stats_team_1 <- filter(s2021, TeamID == team_1_id)
  stats_team_2 <- filter(s2021, TeamID == team_2_id) %>% 
  rename_all(~ paste0("opposing",.)) 
  bound_cols <- bind_cols(stats_team_1, stats_team_2)
  pred <- predict(fit, newdata = bound_cols, type = "response")
  return(pred)
}

predictor_fn(team_1 = teams_in_turn[1], team_2 = teams_in_turn[2])

bracket_ <- bracket %>% 
  # missing app st. ID 1111
  filter(team != "app st.")

probs <- map2_dbl(bracket_$teamid, bracket_$otherteamid, predictor_fn)
# app state is missing so I am assigning it a 0 pob of winning.
probs <- c(probs[1:16], "0", probs[17:33])

bracket <- bracket %>% 
  mutate(team_prob = as.numeric(probs),
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
