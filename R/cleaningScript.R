library(tidyverse) 

list_of_dfs <- sapply(paste0("data/", dir("data")), read_csv, USE.NAMES = TRUE)

games <- list_of_dfs$`data/MConferenceTourneyGames.csv` %>% 
  transmute(gameid = paste0(DayNum, WTeamID, LTeamID),
            Season, ConfAbbrev) 

seasionsoutcomes <- list_of_dfs$`data/MRegularSeasonDetailedResults.csv` %>% 
  left_join( list_of_dfs$`data/MTeams.csv`, by = c("WTeamID" = "TeamID")) %>% 
  filter(Season %in% c(2019, 2020, 2021)) %>% 
  rename(WTeamName = TeamName) %>% 
  left_join( list_of_dfs$`data/MTeams.csv`, by = c("LTeamID" = "TeamID")) %>% 
  select(1:7) %>% 
  pivot_longer(cols = ends_with("ID"),
               names_to = "outcome", 
               values_to = "TeamID") %>% 
  mutate(win = if_else(outcome == "WTeamID", 1 ,0),
         TeamID = as.character(TeamID),
         Season = as.character(Season)) %>% 
  select(-outcome, -DayNum) %>% 
  rename(season = Season)

stats_fn <- function (directory) {
  stats <- sapply(paste0(directory, "/", dir(directory)),
                  readxl::read_excel, USE.NAMES = TRUE)
  stats <- plyr::join_all(stats, by= "Team")
  stats <- stats[, !duplicated(colnames(stats), fromLast = TRUE)]
  return(stats)
}

stats <- sapply(list.dirs("se_data")[-1], stats_fn)
selector <- function (df, cols = co) {
  grabbed <- select(df, contains(cols))
  return(grabbed)
}

a<- colnames(stats$`se_data/se_2019`)
b<- colnames(stats$`se_data/se_2020`)
c<- colnames(stats$`se_data/se_2021`)

co <- as.data.frame(table(c(a, b, c))) %>% 
  filter(Freq == 3) %>% 
  mutate(Var1 = as.character(Var1)) %>% 
  .$Var1


nameandID <- list_of_dfs$`data/MTeamSpellings.csv` %>% 
  mutate(sp = str_remove_all(TeamNameSpelling, "[^a-zA-Z0-9]"))

team_stats <- sapply(stats, selector) %>% 
  bind_rows(.id = "id") %>% 
  select(-contains("opp"), -`REB MAR`, -ORebs, -DRebs, -TOPG) %>% 
  mutate(season = str_extract(id,"([0-9]+).*$"), .before = id) %>% 
  janitor::clean_names() %>% 
  select(-id) %>% 
  relocate(team, .before = season) %>% 
  mutate(team = str_remove_all(tolower(team), "(?=\\().*?(?<=\\))"),
         team = str_remove_all(team, "[[:punct:] ]+")) %>% 
  left_join(nameandID, by = c("team" = "sp")) %>% 
  # Drops 8 teams, all with W-L ratios >.5
  drop_na() %>% 
  mutate(TeamID = as.character(TeamID))
# Here is complete df of team stats from 2019 to 2021

merged <- seasionsoutcomes %>% 
  left_join(team_stats, by = c('TeamID', 'season')) %>% 
  drop_na() %>% 
  select(-TeamNameSpelling)

merged %>% View()

merged %>% 
  write_csv(here::here("data", "merged.csv"))

merged <- readr::read_csv(here::here("data", "merged.csv"))

