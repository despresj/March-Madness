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

# saveRDS(logistic_model_score, here::here("cache", "logistic_model_score.RDS"))


logistic_model_score %>% 
summarise(mean = mean(score, na.rm = TRUE),
             sd = sd(score, na.rm = TRUE),
            t_stat = mean / sd, 
            p = pt(t_stat, n() - 1, lower.tail = FALSE))



# poisson scoring ---------------------------------------------------------

posson_model_score <- toscore(posson_prediction) %>% 
  mutate(predicted_difference = predicted_score - other_predicted_score,
         actual_difference = teamscore - otherteamscore,
         score = predicted_difference - actual_difference) %>% 
  mutate(predicted_winner = if_else(predicted_difference > 0, team, other_team),
         outcome = if_else(predicted_winner == winner, "Correct", "Incorrect")) 


# saveRDS(posson_model_score, here::here("cache", "posson_model_score.RDS"))


posson_model_score %>% 
  summarise(mean = mean(score, na.rm = TRUE),
            sd = sd(score, na.rm = TRUE),
            t_stat = mean / sd, 
            p = pt(t_stat, n() - 1, lower.tail = FALSE))

# multinomeal scoring -----------------------------------------------------

multinomeal_model_score  <- toscore(multinom_prediction) %>% 
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
  # select(`<-12`:`>13`, fifth_xtile, probs) %>%
  mutate(score = if_else(probs > 0.25, (probs * 4), (-1/4)*(1 - probs))) 
multinomeal_model_score 
sum(multinomeal_model_score$score, na.rm = T)

colnames(multinomeal_model_score)
  
# saveRDS(logistic_model_score, here::here("cache", "logistic_model_score.RDS"))

multinomeal_model_score <- multinomeal_model_score %>% 
  mutate(predicted_winner = if_else(`<-12` + `-12:-4` < `other4:13` + `>13`, 
                                  team, other_team),
         outcome = if_else(predicted_winner == winner, "Correct", "Incorrect"))

# saveRDS(multinomeal_model_score, here::here("cache", "multinomeal_model_score.RDS"))

