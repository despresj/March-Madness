library(tidymodels)

options(tibble.print_max = 50, tibble.print_min = 30)

results <- readr::read_csv(here::here("data", "results.csv"))
logistic_predictions <- readRDS(here::here("cache", "logistic_predictions.RDS"))
posson_prediction <- readRDS(here::here("cache", "posson_prediction.RDS"))
multinom_prediction <- readRDS(here::here("cache", "multinom_prediction.RDS"))


gameplayed <- results %>% 
  mutate(gameid = paste0(teamid, "vs", otherteamid))


# logistic scoring --------------------------------------------------------

toscore <- function (df) {
  df %>% 
    mutate(gameid = paste0(teamid, "vs", otherid)) %>% 
    filter(gameid %in% pull(gameplayed, gameid)) %>% 
    left_join(gameplayed, by = c("team", "game", "teamid", "gameid"))
  
}

logistic_model_score <- toscore(logistic_predictions) %>% 
  mutate(score = if_else(predicted_winner == winner, predicted_winner_probs, -1*predicted_winner_probs)) 

logistic_model_score %>% 
summarise(mean = mean(score, na.rm = TRUE),
             sd = sd(score, na.rm = TRUE),
            t_stat = mean / sd, 
            p = pt(t_stat, n() - 1, lower.tail = FALSE))


# poisson scoring ---------------------------------------------------------

posson_prediction  <- toscore(posson_prediction) %>% 
  mutate(predicted_difference = predicted_score - other_predicted_score,
         actual_difference = teamscore - otherteamscore,
         score = predicted_difference - actual_difference) 

posson_model_score %>% 
  summarise(mean = mean(score, na.rm = TRUE),
            sd = sd(score, na.rm = TRUE),
            t_stat = mean / sd, 
            p = pt(t_stat, n() - 1, lower.tail = FALSE))

# multinomeal scoring -----------------------------------------------------

xtile_matcher <- function (x) {
  ifelse(x > 12 , test$`<-12` , 
         ifelse(x >= -12 & x < -4, test$`-12:-4`,
                ifelse(-4 & x <  4, test$`-4:4`,
                       ifelse(x >= 4 & x < 13, test$`4:13`, test$`>13`))))
}

test <- toscore(multinom_prediction) %>% 
  mutate(diff = teamscore - otherteamscore,
  fifth_xtile = case_when(diff <  -12             ~ '<-12',
                          diff >= -12 & diff < -4 ~ '-12:-4',
                          diff >=  -4 & diff <  4 ~ '-4:4',
                          diff >=   4 & diff < 13 ~ '4:13',
                          diff >= 13               ~ '>13'
  ),
  probs = case_when(diff <  -12              ~ `<-12`,
                    diff >= -12 & diff < -4  ~ `-12:-4`,
                    diff >=  -4 & diff <  4  ~ `-4:4`,
                    diff >=   4 & diff < 13  ~ `4:13`,
                    diff >= 13               ~ `>13`)) %>% 
  select(`<-12`:`>13`, fifth_xtile, probs) %>%  # TODO: come up with a way to score this
  mutate(score = if_else(probs > 0.25, probs * 4, 1-probs))

