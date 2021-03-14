library(tidyverse)
# options(tibble.print_max = 30, tibble.print_min = 30)

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


season

# 2019 Season Games --------------------------------------------------------------

seasion2019outcome <- season %>%
  filter(Season == 2019) %>% 
  select(WTeamID, LTeamID, WTeamName, LTeamName, LScore, WScore) %>%
  mutate(game = paste(WTeamName, "v.", LTeamName),
         IDs = paste(WTeamID, "vs", LTeamID)) %>% 
  pivot_longer(cols = ends_with("Name"),
               names_to = "outcome", 
               values_to = "team") %>% 
  mutate(win = if_else(outcome == "WTeamName", 1, 0),
         teamid = if_else(win == 1, WTeamID, LTeamID),
         points_scored = ifelse(win == 1, WScore, LScore),
         TeamID = as.character(teamid),
          team = tolower(team)
  ) %>% 
  select(-WTeamID, -LTeamID, -LScore,  -WScore, -teamid, -outcome) %>% 
  separate(IDs, c("A", "B"), sep = " vs ") %>% 
  mutate(oposingTeamID = if_else(TeamID == A, B, A)) 

seasion2019outcome %>% skimr::skim()
# 100% completion

# 2019 Team Stats --------------------------------------------------------------------

list_of_stats <- sapply(paste0("ncaateamstats/", dir("ncaateamstats")), readxl::read_excel, USE.NAMES = TRUE)
list_of_stats

team_dict <- list_of_dfs$`data/MTeamSpellings.csv` %>%
left_join(list_of_dfs$`data/MTeams.csv`, by = "TeamID") %>% 
  mutate(Team = str_replace_all(tolower(TeamName), "[^a-zA-Z0-9]", ""),
       TeamSp = str_replace_all(tolower(TeamNameSpelling), "[^a-zA-Z0-9]", "")) %>% 
  select(TeamID, Team, TeamSp)
  
   



teams <- plyr::join_all(list_of_stats, by= "Team")
teams <- teams[, !duplicated(colnames(teams), fromLast = TRUE)] 

# 2021 Team Stats ---------------------------------------------------------
list_of_stats_2021 <- sapply(paste0("currentseson/", dir("currentseson")), readxl::read_excel, USE.NAMES = TRUE)
list_of_stats_2021

stats_2021 <- plyr::join_all(list_of_stats_2021, by= "Team")
stats_2021 <- stats_2021 [, !duplicated(colnames(stats_2021 ), fromLast = TRUE)] 

stats_2021
skimr::skim(team_dict)
# 100% completion



# TODO: NEED MI AND MISTATE DISTINCT

# fuzzjoined2019 <- 
  teams <- teams %>% janitor::clean_names() %>% 
  tibble() %>% 
    mutate(team = str_remove_all(tolower(team), "(?=\\().*?(?<=\\))"),
           team = str_remove_all(team, "[[:punct:] ]+"))
  
team_dict <- team_dict %>% 
    group_by(TeamID) %>% 
    distinct(TeamID, .keep_all = TRUE) 

# View(team_dict)
# View(teams)

team_dict %>% 
  select(TeamSp, TeamID) %>% 
  as.data.frame() %>% 
  head(25)

ci_str_detect <- function(x, y){str_detect(x, regex(y, ignore_case = TRUE))}


fuzzjoined2019 <- teams %>% 
fuzzyjoin::fuzzy_left_join(team_dict, match_fun = ci_str_detect, by = c("team" = "TeamSp")) %>% 
  drop_na() %>% 
  select(-Team) %>% 
  relocate(TeamSp:TeamID, .after = team) %>% 
  mutate(TeamID = as.character(TeamID))

# https://stats.ncaa.org/rankings/change_sport_year_div

fuzzjoined2019

opo <- fuzzjoined2019 %>%
  rename_all(~(paste0("opo_",  make.names(names(fuzzjoined2019)))))

team_ <- fuzzjoined2019 %>%
  rename_all(~(paste0("team_",  make.names(names(fuzzjoined2019)))))

write_csv(team_, here::here("data", "teamstat.csv"))
write_csv(opo, here::here("data", "oposestat.csv"))

opo
team_

skimr::skim(seasion2019outcome)
skimr::skim(team_)

merged <- seasion2019outcome %>% 
  mutate(TeamID = as.character(TeamID)) %>% 
  # What happened here ?
  left_join(team_, by = c("TeamID" = "team_TeamID")) %>% 
  full_join(opo, by = c("TeamID" = "opo_TeamID")) %>%
  # Something is wrong with this join 90% ish completion rate
  # Deal with it for now
  drop_na() %>% 
  select(-A, -B)

merged %>% View()

skimr::skim(merged)

merged %>% 
  write_csv(here::here("data", "merged.csv"))


team <- season %>%
  filter(Season == 2019) %>% 
  select(WTeamID, LTeamID, WTeamName, LTeamName, LScore, WScore) %>%
  mutate(game = paste(WTeamName, "v.", LTeamName),
         IDs = paste(WTeamID, "vs", LTeamID)) %>% 
  pivot_longer(cols = ends_with("Name"),
               names_to = "outcome", 
               values_to = "team")



df <- list_of_dfs$`data/MTeamSpellings.csv` %>% 
  mutate(sp = str_remove_all(TeamNameSpelling, "[^a-zA-Z0-9]"))

teams %>% 
  # select(team) %>%
  left_join(df, by = c("team" = "sp")) %>% 
  skimr::skim()

team %>% 
  mutate(new = tolower(team)) %>% 
  mutate(sp = str_remove_all(new, "[^a-zA-Z0-9]")) %>% 
  left_join(teams, by = "sp") %>% 
  skimr::skim()
