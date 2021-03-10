library(tidyverse)
# options(tibble.print_max = 10, tibble.print_min = 30) 

list_of_dfs <- sapply(paste0("data/", dir("data")), read_csv, USE.NAMES = TRUE)
list_of_stats <- sapply(paste0("ncaateamstats/", dir("ncaateamstats")), readxl::read_excel, USE.NAMES = TRUE)

list_of_stats

teams <- plyr::join_all(list_of_stats, by= "Team")
teams <- teams[, !duplicated(colnames(teams), fromLast = TRUE)] 

team_dict <- list_of_dfs$`data/MTeamSpellings.csv` %>%
left_join(list_of_dfs$`data/MTeams.csv`, by = "TeamID") %>% 
  mutate(Team = str_replace_all(tolower(TeamName), "[^a-zA-Z0-9]", ""))
  

View(team_dict)

teams %>% janitor::clean_names() %>% 
  tibble() %>% 
  mutate(Team = str_split_fixed(teams$Team, " \\(|\\)", 2)[,1],
         Team = str_replace_all(tolower(Team), "[^a-zA-Z0-9]", "")) %>% 
  full_join(team_dict, by = "Team")

list_of_dfs$`data/MTeamSpellings.csv`


separate(x, c("A","B"), sep = "([.?:])")
  mutate()
  left_join(list_of_dfs$`data/MTeamSpellings.csv`)




View(teams)
# https://stats.ncaa.org/rankings/change_sport_year_div