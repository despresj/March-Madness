library(tidymodels)
theme_set(theme_test())
source(here::here("R", "bracket.R"))
source(here::here("R", 'cleaningScript.R'))

# merged <- readr::read_csv(here::here("data", "merged.csv"))


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
# summary(fit)

s2021 <- team_stats %>% 
  filter(season == 2021, 
         TeamID %in% c(begining_bracket$teamid, begining_bracket$otherteamid)) %>% 
  distinct(TeamID, .keep_all = TRUE) %>% 
  select(-season) 

predictor_fn <- function (team_1_id, team_2_id) {
  stats_team_1 <- filter(s2021, TeamID == team_1_id)
  stats_team_2 <- filter(s2021, TeamID == team_2_id) %>% 
  rename_all(~ paste0("opposing",.)) 
  bound_cols <- bind_cols(stats_team_1, stats_team_2)
  pred <- predict(fit, newdata = bound_cols, type = "response")
  return(pred)
}

# First round -------------------------------------------------------------

begining_bracket

possibly_predictor_fn <- possibly(.f = predictor_fn, otherwise = "ERROR")

probs <- map2_dbl(.x = begining_bracket$teamid, 
                  .y = begining_bracket$otherteamid, 
                  .f = possibly_predictor_fn)

probs

add_probs <- function(df, probs){
  
  df <- df %>% 
    mutate(team_prob = probs,
           otherteam_prob = 1 - team_prob, 
           game = paste0(team, " vs. ", otherteam),
           predicted_winner = if_else(team_prob > 0.5, team, otherteam),
           predicted_winnerid = if_else(team_prob > 0.5, teamid, otherteamid),
           game = paste0(team, " vs. ", otherteam))
  return(df)
}

begining_bracket <- add_probs(begining_bracket, probs = probs)

nice_format <- function(df){
  output <- df %>%
    mutate(pred_winner_prob = if_else(team_prob > 0.5, team_prob, otherteam_prob),
           pred_loser_prob = if_else(team_prob < 0.5, team_prob, otherteam_prob)) %>% 
    select(game, predicted_winner, 
           pred_winner_prob, pred_loser_prob)
  return(output)
}


nice_format(begining_bracket)

# second round ------------------------------------------------------------

advance_round <- function(df){
  df <- df %>% 
    select(predicted_winner, predicted_winnerid) %>% 
    rename(team = predicted_winner, teamid = predicted_winnerid) %>% 
    mutate(game = rep(c("team", "otherteam"), nrow(df)/2))
  
  return(df)
}

second_round  <- advance_round(begining_bracket)

align_teams <- function(df){
  
   team <- filter(df, game != "team")
  other <- filter(df, game == "team")
  
  output <- other %>% 
    rename_all(~ paste0("other",.)) %>% 
    bind_cols(team) 
  
  return(output)
}

second_round_games <- align_teams(second_round)

second_round_games 

probs <- map2_dbl(.x = second_round_games$teamid, 
                  .y = second_round_games$otherteamid, 
                  .f = possibly_predictor_fn)

second_round <- add_probs(second_round_games, probs)

nice_format(second_round)

# sweet sixteen -------------------------------------------------------------

{sweet_sixteen <- advance_round(second_round)

sweet_sixteen_games <- align_teams(sweet_sixteen)

sweet_sixteen_probs <- map2_dbl(.x = sweet_sixteen_games$teamid, 
                                .y = sweet_sixteen_games$otherteamid, 
                                .f = possibly_predictor_fn)

sweet_sixteen_prediction <- add_probs(sweet_sixteen_games, probs = sweet_sixteen_probs)

nice_format(sweet_sixteen_prediction)}


# elite eight -------------------------------------------------------------

{elite_eight <- advance_round(sweet_sixteen_prediction)

elite_eight_games <- align_teams(elite_eight)

elite_eight_probs <- map2_dbl(.x = elite_eight_games$teamid, 
                                .y = elite_eight_games$otherteamid, 
                                .f = possibly_predictor_fn)

elite_eight_prediction <- add_probs(elite_eight_games, elite_eight_probs)

nice_format(elite_eight_prediction)}


# final four --------------------------------------------------------------

{final_four <- advance_round(elite_eight_prediction)

final_four_games <- align_teams(final_four)

final_four_probs <- map2_dbl(.x = final_four_games$teamid, 
                             .y = final_four_games$otherteamid, 
                             .f = possibly_predictor_fn)

final_four_prediction <- add_probs(final_four_games, final_four_probs)

nice_format(final_four_prediction)
}

# championship ------------------------------------------------------------

{championship <- advance_round(final_four_prediction)

championship_game <- align_teams(championship)

championship_probs <- map2_dbl(.x = championship_game$teamid, 
                               .y = championship_game$otherteamid, 
                               .f = possibly_predictor_fn)

championship_prediction  <- add_probs(championship_game, championship_probs)

nice_format(championship_prediction)}

