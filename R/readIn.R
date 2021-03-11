library(tidyverse)
options(tibble.print_max = 30, tibble.print_min = 30)

list_of_dfs <- sapply(paste0("data/", dir("data")), read_csv, USE.NAMES = TRUE)


# Season -----------------------------------------------------------------
games <- list_of_dfs$`data/MConferenceTourneyGames.csv` %>% 
  transmute(gameid = paste0(DayNum, WTeamID, LTeamID),
            Season, ConfAbbrev) 

season <- list_of_dfs$`data/MRegularSeasonDetailedResults.csv` %>% 
  left_join( list_of_dfs$`data/MTeams.csv`, by = c("WTeamID" = "TeamID")) %>% 
  select(-ends_with("Season")) %>% 
  rename(WTeamName = TeamName) %>% 
  left_join( list_of_dfs$`data/MTeams.csv`, by = c("LTeamID" = "TeamID")) %>% 
  rename(LTeamName = TeamName,
         Winfieldgoalsmade = WFGM,
         Winfieldgoalsattempted = WFGA,
         Winthreepointersmade = WFGM3,
         Winthreepointersattempted = WFGA3,
         Winfreethrowsmade = WFTM,
         Winfreethrowsattempted = WFTA,
         Winoffensiverebounds = WOR,
         Windefensiverebounds = WDR,
         Winassists = WAst,
         Winturnoverscommitted = WTO,
         Winsteals = WStl,
         Winblocks = WBlk,
         Winpersonalfoulscommitted = WPF,
         Lfieldgoalsmade = LFGM,
         Lfieldgoalsattempted = LFGA,
         Lthreepointersmade = LFGM3,
         Lthreepointersattempted = LFGA3,
         Lfreethrowsmade = LFTM,
         Lfreethrowsattempted = LFTA,
         Loffensiverebounds = LOR,
         Ldefensiverebounds = LDR,
         Lassists = LAst,
         Lturnoverscommitted = LTO,
         Lsteals = LStl,
         Lblocks = LBlk,
         Lpersonalfoulscommitted = LPF
  ) %>%
  relocate(LTeamName, .after = LTeamID) %>% 
  relocate(WTeamName, .after = WTeamID) %>% 
  mutate(diff = (Winfieldgoalsmade - Lfieldgoalsmade),
         std_dif = diff / sd(diff)) %>% 
  mutate(gameid = paste0(DayNum, WTeamID, LTeamID)) %>% 
  full_join(games, by = "gameid") %>% 
  select(-ends_with(".y"))


Season


  

# 2019 Season Games --------------------------------------------------------------

# TODO: The game stats need to be combined with the team stats. 
# From there we are ready to rock and roll

season2019 <- season %>%
  
  filter(Season == 2018) %>% View()


season2019 <- season2019 %>% 
  # select(WTeamName, LTeamName, WScore, LScore) %>%
  pivot_longer(cols = ends_with("Name"), values_to = "Team") %>% 
  rename(outcome = name) %>% 
  mutate(outcome = str_replace_all(outcome, "TeamName", ""),
         diff = if_else(outcome == "W", diff * -1, diff), 
         std_dif = if_else(outcome == "W", std_dif * -1, std_dif))


# 2019 Team Stats --------------------------------------------------------------------

list_of_stats <- sapply(paste0("ncaateamstats/", dir("ncaateamstats")), readxl::read_excel, USE.NAMES = TRUE)


team_dict <- list_of_dfs$`data/MTeamSpellings.csv` %>%
left_join(list_of_dfs$`data/MTeams.csv`, by = "TeamID") %>% 
  mutate(Team = str_replace_all(tolower(TeamName), "[^a-zA-Z0-9]", ""),
       TeamSp = str_replace_all(tolower(TeamNameSpelling), "[^a-zA-Z0-9]", "")) %>% 
  select(TeamID, Team, TeamSp)
  

teams <- plyr::join_all(list_of_stats, by= "Team")
teams <- teams[, !duplicated(colnames(teams), fromLast = TRUE)] 

ci_str_detect <- function(x, y){str_detect(x, regex(y, ignore_case = TRUE))}

fuzzjoined2019 <- teams %>% janitor::clean_names() %>% 
  tibble() %>% 
  select(-team) %>% 
  mutate(Team = str_split_fixed(teams$Team, " \\(|\\)", 2)[,1],
         Team = str_replace_all(tolower(Team), "[^a-zA-Z0-9]", "")) %>%
  fuzzyjoin::fuzzy_left_join(team_dict, match_fun = ci_str_detect, by = c("Team" = "TeamSp")) %>%
  distinct(x3fg, x3fga, blks, bkpg, ast, apg, opp_fg, .keep_all = TRUE) %>% 
  select(-ends_with(".x")) %>% 
  rename(Team = Team.y)
  


# https://stats.ncaa.org/rankings/change_sport_year_div