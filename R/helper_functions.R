align_teams <- function(df){
  
  team <- filter(df, game != "team")
  other <- filter(df, game == "team")
  
  output <- other %>% 
    rename_all(~ paste0("other",.)) %>% 
    bind_cols(team) 
  
  return(output)
}

advance_round <- function(df){
  df <- df %>% 
    select(predicted_winner, predicted_winnerid) %>% 
    rename(team = predicted_winner, teamid = predicted_winnerid) %>% 
    mutate(game = rep(c("team", "otherteam"), nrow(df)/2))
  
  return(df)
}

nice_format <- function(df){
  output <- df %>%
    mutate(pred_winner_prob = if_else(team_prob > 0.5, team_prob, otherteam_prob),
           pred_loser_prob = if_else(team_prob < 0.5, team_prob, otherteam_prob)) %>% 
    select(game, predicted_winner, 
           pred_winner_prob, pred_loser_prob)
  
  return(output)
}

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

predictor_fn <- function (team_1_id, team_2_id) {
  stats_team_1 <- filter(s2021, TeamID == team_1_id)
  stats_team_2 <- filter(s2021, TeamID == team_2_id) %>% 
    rename_all(~ paste0("opposing",.)) 
  bound_cols <- bind_cols(stats_team_1, stats_team_2)
  pred <- predict(fit, newdata = bound_cols, type = "response")
  
  return(pred)
}
