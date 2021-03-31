library(tidymodels)
source(here::here("R", "bracket.R"))
source(here::here("R", "helper_functions.R"))
source(here::here("R", 'cleaningScript.R'))
theme_set(theme_test())
options(tibble.print_min = 20)

team1id <- pull(s2021, TeamID)
team2id <- pull(s2021, TeamID) 

ids <- crossing(teamid = team1id, other = team2id) %>% 
  distinct() %>%
  filter(teamid != other) %>% 
  # note choose(64,2) = 2016 Im removing double counts.
  top_n(2016) %>% 
  left_join(s2021, by = c("other" = "TeamID")) %>% 
  rename(other_team = team) %>% 
  select(teamid:other_team) %>% 
  left_join(s2021, by = c("teamid" = "TeamID")) %>% 
  mutate(game = paste0(team, " vs. ", other_team)) %>% 
  select(team, other_team,game, teamid, otherid = other)
  
start <- Sys.time()
predicted_games <- ids %>% 
  mutate(predicted_probs = map2_dbl(.x = ids$teamid, 
                                    .y = ids$otherid, 
                                    .f = logistic_predictor))
# about 30 seconds to run
paste0("runtime: ", round(Sys.time() - start, 2))

predicted_games %>% 
  mutate(  
    predicted_winner = if_else(predicted_probs > .5, team, other_team),
    predicted_winner_probs = if_else(predicted_probs > .5, predicted_probs , 1 - predicted_probs),
    predicted_loser_probs = 1 - predicted_winner_probs,
    .after = game
  )

# TODO: rename possibly_predictor_fn

# 
# fit <- glm(win ~ x3fg +
#              opposingx3fg +
#              # field goal pct
#              fg_percent +
#              opposingfg_percent +
#              # free throws
#              ft_percent +
#              opposingft_percent +
#              # rebound per game
#              rpg + 
#              opposingrpg +
#              # steels
#              st +
#              opposingst +
#              #turnover
#              to +
#              opposingto +
#              # blocks
#              opposingbkpg +
#              bkpg,
#            data = merged, family = "binomial")
# 
# logistic_predictor_fn <- function (team_1_id, team_2_id) {
#   stats_team_1 <- filter(s2021, TeamID == team_1_id)
#   stats_team_2 <- filter(s2021, TeamID == team_2_id) %>% 
#     rename_all(~ paste0("opposing",.)) 
#   bound_cols <- bind_cols(stats_team_1, stats_team_2)
#   pred <- predict(fit, newdata = bound_cols, type = "response")
#   
#   return(pred)
# }
# 
# logistic_predictor <- possibly(.f = logistic_predictor_fn, otherwise = "ERROR")
