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
  
crossing(team1, team2) %>% 
  distinct() %>%
  filter(team1 != team2) %>% 
  # note choose(64,2) = 2016 Im removing double counts.
  top_n(2016) %>% 
  left_join(team_stats, by = team)

