source(here::here("R", "cleaningScript.R"))
# TODO: write all script files to csv and read in
source(here::here("R", "helper_functions.R"))
library(tidymodels)
theme_set(theme_test())
options(tibble.print_min = 20)

team1id <- pull(s2021, TeamID)
team2id <- pull(s2021, TeamID) 

ids <- crossing(teamid = team1id, other = team2id) %>% 
  distinct() %>%
  filter(teamid != other) %>% 
  top_n(2016) %>%   # choose(64,2) = 2016 (removing double counts)
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
# This takes about 30 seconds to run
paste0("runtime: ", round(Sys.time() - start, 2))


predicted_games %>% 
  mutate(  
    predicted_winner = if_else(predicted_probs > .5, team, other_team),
    predicted_winner_probs = if_else(predicted_probs > .5, predicted_probs , 1 - predicted_probs),
    predicted_loser_probs = 1 - predicted_winner_probs,
    prediction_points = predicted_winner_probs - predicted_loser_probs,
    .after = game
  )


# poisson -----------------------------------------------------------------


fit_poisson <- glm(team_score ~ x3fg +
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
             data = merged, family = poisson(link = "log"))

summary(fit_poisson)


poisson_predictor_fn <- function (team_1_id, team_2_id) {
  stats_team_1 <- filter(s2021, TeamID == team_1_id)
  stats_team_2 <- filter(s2021, TeamID == team_2_id) %>%
    rename_all(~ paste0("opposing",.))
  bound_cols <- bind_cols(stats_team_1, stats_team_2)
  pred <- predict(fit_poisson, newdata = bound_cols, type = "response")

  return(pred)
}
# 

poisson_predictor <- possibly(.f = poisson_predictor_fn, otherwise = "ERROR")

ids <- crossing(teamid = team1id, other = team2id) %>% 
  distinct() %>%
  filter(teamid != other) %>% 
  left_join(s2021, by = c("other" = "TeamID")) %>% 
  rename(other_team = team) %>% 
  select(teamid:other_team) %>% 
  left_join(s2021, by = c("teamid" = "TeamID")) %>% 
  mutate(game = paste0(team, " vs. ", other_team)) %>% 
  select(team, other_team,game, teamid, otherid = other)


start <- Sys.time()
predicted_games <- ids %>% 
  mutate(predicted_score = map2_dbl(.x = ids$teamid, 
                                    .y = ids$otherid, 
                                    .f = poisson_predictor),
         # TODO: this is hiddeous come up with a better way
         other_predicted_score = map2_dbl(.x = ids$otherid, 
                                    .y = ids$teamid, 
                                    .f = poisson_predictor))
# this takes about a 160 secs to run
paste0("runtime: ", round(Sys.time() - start, 2))



# mulitnom ----------------------------------------------------------------


fit_multinom <- VGAM::vglm(x_tile ~ x3fg +
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
                 bkpg, family = VGAM::cumulative(parallel=TRUE),
                 data = merged)
  
multinom_predictor_fn <- function (team_1_id, team_2_id) {
  stats_team_1 <- filter(s2021, TeamID == team_1_id)
  stats_team_2 <- filter(s2021, TeamID == team_2_id) %>%
  rename_all(~ paste0("opposing",.))
  bound_cols <- bind_cols(stats_team_1, stats_team_2)
  pred <- VGAM::predict(fit_multinom, newdata = bound_cols, type = "response")
  
  return(pred)
}

multinom_predictor <- possibly(.f = multinom_predictor_fn, otherwise = "ERROR")


start <- Sys.time()
predicted_games <- ids %>% 
  mutate(
    predicted_score = map2(.x = ids$teamid, 
                           .y = ids$otherid, 
                           .f = multinom_predictor),
         # TODO: this is hiddeous come up with a better way
   other_predicted_score = map2(.x = ids$otherid, 
                                .y = ids$teamid, 
                                .f = multinom_predictor))
# this takes about a 160 secs to run
paste0("runtime: ", round(Sys.time() - start, 2))

predicted_games %>% 
  unnest_wider(predicted_score) %>% 
  # TODO: fix colnames to proportion
  unnest_wider(other_predicted_score)
