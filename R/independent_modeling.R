# source(here::here("R", "cleaningScript.R"))

library(tidymodels)
source(here::here("R", "helper_functions.R"))
ids <- readr::read_csv(here::here("data", "ids.csv"))
s2021 <- readr::read_csv(here::here("data", "s2021.csv"))
merged <- readr::read_csv(here::here("data", "merged.csv"))
team_stats <- readr::read_csv(here::here("data", "team_stats.csv"))
begining_bracket <- readr::read_csv(here::here("data", "begining_bracket.csv"))
options(tibble.print_min = 20)

# TODO: recipes::step_normalize() try that see if there is a difference

# logsitic fit ------------------------------------------------------------

logistic_fit <- glm(win ~ x3fg +
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

start <- Sys.time()

logistic_predictions <- ids %>%
  mutate(predicted_probs = map2_dbl(.x = ids$teamid,
                                    .y = ids$otherid,
                                    .f = logistic_predictor)) %>%
   mutate(
    predicted_winner = if_else(predicted_probs > .5, team, other_team),
    predicted_winner_probs = if_else(predicted_probs > .5, predicted_probs , 1 - predicted_probs),
    predicted_loser_probs = 1 - predicted_winner_probs,
    prediction_points = predicted_winner_probs - predicted_loser_probs,
    .after = game
  )
paste0("runtime: ", round(Sys.time() - start, 2))

saveRDS(logistic_predictions, here::here("cache", "logistic_predictions.RDS"))


logistic_predictions <- readRDS(here::here("cache", "logistic_predictions.RDS"))
logistic_predictions


# poisson -----------------------------------------------------------------

# fit_poisson <- glm(team_score ~ x3fg +
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
#              data = merged, family = poisson(link = "log"))
# 
# summary(fit_poisson)
# 
# 
# poisson_predictor_fn <- function (team_1_id, team_2_id) {
#   stats_team_1 <- filter(s2021, TeamID == team_1_id)
#   stats_team_2 <- filter(s2021, TeamID == team_2_id) %>%
#     rename_all(~ paste0("opposing",.))
#   bound_cols <- bind_cols(stats_team_1, stats_team_2)
#   pred <- predict(fit_poisson, newdata = bound_cols, type = "response")
# 
#   return(pred)
# }
# 
# 
# poisson_predictor <- possibly(.f = poisson_predictor_fn, otherwise = "ERROR")
# 
# start <- Sys.time()
# posson_prediction <- ids %>%
#   mutate(predicted_score = map2_dbl(.x = ids$teamid,
#                                     .y = ids$otherid,
#                                     .f = poisson_predictor),
#          # TODO: this is hiddeous come up with a better way
#          other_predicted_score = map2_dbl(.x = ids$otherid,
#                                     .y = ids$teamid,
#                                     .f = poisson_predictor))
# paste0("runtime: ", round(Sys.time() - start, 2))
# # this takes about a 160 secs to run
# saveRDS(posson_prediction, here::here("cache", "posson_prediction.RDS"))

posson_prediction <- readRDS(here::here("cache", "posson_prediction.RDS"))
posson_prediction

# mulitnom ----------------------------------------------------------------
#
# fit_multinom <- VGAM::vglm(x_tile ~ x3fg +
#                  opposingx3fg +
#                  # field goal pct
#                  fg_percent +
#                  opposingfg_percent +
#                  # free throws
#                  ft_percent +
#                  opposingft_percent +
#                  # rebound per game
#                  rpg +
#                  opposingrpg +
#                  # steels
#                  st +
#                  opposingst +
#                  #turnover
#                  to +
#                  opposingto +
#                  # blocks
#                  opposingbkpg +
#                  bkpg, family = VGAM::cumulative(parallel=TRUE),
#                  data = merged)
# 
# multinom_predictor_fn <- function (team_1_id, team_2_id) {
#   stats_team_1 <- filter(s2021, TeamID == team_1_id)
#   stats_team_2 <- filter(s2021, TeamID == team_2_id) %>%
#   rename_all(~ paste0("opposing",.))
#   bound_cols <- bind_cols(stats_team_1, stats_team_2)
#   pred <- VGAM::predict(fit_multinom, newdata = bound_cols, type = "response")
# 
#   return(pred)
# }
# 
# multinom_predictor <- possibly(.f = multinom_predictor_fn, otherwise = "ERROR")
# 
# start <- Sys.time()
# multinom_prediction <- ids %>%
#   mutate(
#     predicted_score = map2(.x = ids$teamid,
#                            .y = ids$otherid,
#                            .f = multinom_predictor),
#          # TODO: this is hiddeous come up with a better way
#    other_predicted_score = map2(.x = ids$otherid,
#                                 .y = ids$teamid,
#                                 .f = multinom_predictor))
# # this takes about a 160 secs to run
# paste0("runtime: ", round(Sys.time() - start, 2))
# 
# add_name <- function(x){
#   names(x) <- c("<-12", "-12:-4","-4:4", "4:13", ">13")
#   return(x)
# }
# 
# add_name_other <- function(x){
#   names <- c("<-12", "-12:-4","-4:4", "4:13", ">13")
#   names(x) <- paste0("other", names)
#   return(x)
# }
# 
# multinom_prediction <- multinom_prediction  %>%
#   mutate(predicted_score = map(predicted_score, add_name)) %>%
#   unnest_wider(predicted_score) %>%
#   mutate(other_predicted_score = map(other_predicted_score, add_name_other)) %>%
#   unnest_wider(other_predicted_score)
# 
# saveRDS(multinom_prediction, here::here("cache", "multinom_prediction.RDS"))

multinom_prediction <- readRDS(here::here("cache", "multinom_prediction.RDS"))
multinom_prediction