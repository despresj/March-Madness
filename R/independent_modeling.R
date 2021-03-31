library(tidymodels)
source(here::here("R", "bracket.R"))
source(here::here("R", 'cleaningScript.R'))
source(here::here("R", "helper_functions.R"))
theme_set(theme_test())
options(tibble.print_max = 20, tibble.print_min = 20)

s2021 <- team_stats %>% 
  filter(season == 2021, 
         TeamID %in% c(begining_bracket$teamid, begining_bracket$otherteamid)) %>% 
  distinct(TeamID, .keep_all = TRUE) %>% 
  select(-season) 

team1 <- pull(s2021, team)
team2 <- pull(s2021, team) 
  
teams <- crossing(team = team1, other = team2) %>% 
  distinct() %>%
  filter(team != other) %>% 
  # note choose(64,2) = 2016 Im removing double counts.
  top_n(2016)


team1id <- pull(s2021, TeamID)
team2id <- pull(s2021, TeamID) 

start <- system.time()
ids <-  crossing(team = team1id, other = team2id) %>% 
        distinct() %>%
        filter(team != other) %>% 
        # note choose(64,2) = 2016 Im removing double counts.
        top_n(2016) %>% 
        mutate(predicted_probs = map2_dbl(.x = ids$team, 
                                          .y = ids$other, 
                                          .f = possibly_predictor_fn))

system.time() - start
ids

# TODO: join ids into a df.
# TODO: rename possibly_predictor_fn