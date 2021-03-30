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
         TeamID %in% c(begining_bracket$teamid, begining_bracket$otherteamid)) %>% 
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

begining_bracket %>% 
  select(game, team_prob, otherteam_prob, predicted_winner)

# second round ------------------------------------------------------------

advance_round <- function(df){
  df <- df %>% 
    select(predicted_winner, predicted_winnerid) %>% 
    rename(team = predicted_winner, teamid = predicted_winnerid) %>% 
    mutate(game = rep(c("team", "otherteam"), nrow(df)/2))
  
  return(df)
}

second_round  <- advance_round(begining_bracket)

second_round

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

probs

second_round <- add_probs(second_round_games, probs)

second_round

# sweet sixteen -------------------------------------------------------------

sweet_sixteen <- advance_round(second_round)

sweet_sixteen_games <- align_teams(sweet_sixteen)

sweet_sixteen_probs <- map2_dbl(.x = sweet_sixteen_games$teamid, 
         .y = sweet_sixteen_games$otherteamid, 
         .f = possibly_predictor_fn)

sweet_sixteen_prediction <- add_probs(sweet_sixteen_games, probs = sweet_sixteen_probs)

sweet_sixteen_prediction %>% 
  select(game, team_prob, otherteam_prob, predicted_winner)


# elite eight -------------------------------------------------------------




# sweet sixteen -------------------------------------------------------------

winner_selector <- function(df){
    output <- df %>% 
    select(predicted_winner, predicted_winnerid) %>% 
    rename(team = predicted_winner, teamid = predicted_winnerid) %>% 
    mutate(game = rep(c("team", "otherteam"), nrow(df)/2))
    return(output)
}

sweet_sixteen <- winner_selector(df = second_round_prediction) 

team <- sweet_sixteen %>% 
  filter(game != "team")

other <- sweet_sixteen %>% 
  filter(game == "team")

probs <- map2_dbl(.x = team$teamid, 
                  .y = other$teamid, 
                  .f = possibly_predictor_fn)

sweet_sixteen <- other %>% 
  rename_all(~ paste0("opposing",.)) %>% 
  bind_cols(team) %>% 
  mutate(team_prob = as.numeric(probs),
         otherteam_prob = 1 - team_prob, 
         game = paste0(team, " vs. ", opposingteam), 
         predicted_winner = if_else(team_prob > 0.5, team, opposingteam),
         predicted_winnerid = if_else(team_prob > 0.5, teamid, opposingteamid),
         game = paste0(team, " vs. ", opposingteam)) 

sweet_sixteen %>% 
  select(game, predicted_winner, team_prob, otherteam_prob)


# elite eight -------------------------------------------------------------


elite_eight <- sweet_sixteen %>% 
  winner_selector()

team <- elite_eight %>% 
  filter(game != "team")

other <- elite_eight %>% 
  filter(game == "team")
  

probs <- map2_dbl(.x = team$teamid, 
                  .y = other$teamid, 
                  .f = possibly_predictor_fn)

elite_eight <- other %>% 
  rename_all(~ paste0("opposing",.)) %>% 
  bind_cols(team) %>% 
  mutate(team_prob = as.numeric(probs),
         otherteam_prob = 1 - team_prob, 
         game = paste0(team, " vs. ", opposingteam), 
         predicted_winner = if_else(team_prob > 0.5, team, opposingteam),
         predicted_winnerid = if_else(team_prob > 0.5, teamid, opposingteamid),
         game = paste0(team, " vs. ", opposingteam)) 

elite_eight %>% 
  select(game, predicted_winner, team_prob, otherteam_prob)


# final_four --------------------------------------------------------------

final_four <- elite_eight %>% 
  winner_selector()

team <- final_four %>% 
  filter(game != "team")

other <- final_four %>% 
  filter(game == "team")

probs <- map2_dbl(.x = team$teamid, 
                  .y = other$teamid, 
                  .f = possibly_predictor_fn)

final_four <- other %>% 
  rename_all(~ paste0("opposing",.)) %>% 
  bind_cols(team) %>% 
  mutate(team_prob = as.numeric(probs),
         otherteam_prob = 1 - team_prob, 
         game = paste0(team, " vs. ", opposingteam), 
         predicted_winner = if_else(team_prob > 0.5, team, opposingteam),
         predicted_winnerid = if_else(team_prob > 0.5, teamid, opposingteamid),
         game = paste0(team, " vs. ", opposingteam)) 

final_four %>% 
  select(game, predicted_winner, team_prob, otherteam_prob)


# championship ------------------------------------------------------------

championship <- final_four %>% 
  winner_selector()

team <- championship %>% 
  filter(game != "team")

other <- championship %>% 
  filter(game == "team")

probs <- map2_dbl(.x = team$teamid, 
                  .y = other$teamid, 
                  .f = possibly_predictor_fn)

championship <- other %>% 
  rename_all(~ paste0("opposing",.)) %>% 
  bind_cols(team) %>% 
  mutate(team_prob = as.numeric(probs),
         otherteam_prob = 1 - team_prob, 
         game = paste0(team, " vs. ", opposingteam), 
         predicted_winner = if_else(team_prob > 0.5, team, opposingteam),
         predicted_winnerid = if_else(team_prob > 0.5, teamid, opposingteamid),
         game = paste0(team, " vs. ", opposingteam)) 

championship %>% 
  select(game, predicted_winner, team_prob, otherteam_prob)
