library(tidyverse) 
# options(tibble.print_min = 35)

list_of_dfs <- sapply(paste0("rawdata/", dir("rawdata")), read_csv, USE.NAMES = TRUE)

games <- list_of_dfs$`rawdata/MConferenceTourneyGames.csv` %>% 
  transmute(gameid = paste0(DayNum, WTeamID, LTeamID),
            Season, ConfAbbrev) 

seasionsoutcomes <- list_of_dfs$`rawdata/MRegularSeasonDetailedResults.csv` %>% 
  left_join(list_of_dfs$`rawdata/MTeams.csv`, by = c("WTeamID" = "TeamID")) %>% 
  filter(Season %in% c(2019, 2020, 2021)) %>% 
  rename(WTeamName = TeamName) %>% 
  left_join( list_of_dfs$`rawdata/MTeams.csv`, by = c("LTeamID" = "TeamID")) %>% 
  select(1:7) %>% 
  mutate(W = WTeamID, L =  LTeamID) %>% 
  pivot_longer(cols = ends_with("ID"),
               names_to = "outcome", 
               values_to = "TeamID") %>% 
  mutate(win = if_else(outcome == "WTeamID", 1 ,0),
         TeamID = as.character(TeamID),
         Season = as.character(Season)) %>% 
  select(-outcome, -DayNum) %>% 
  rename(season = Season)

seasionsoutcomes

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

a <- colnames(stats$`se_data/se_2019`)
b <- colnames(stats$`se_data/se_2020`)
c <- colnames(stats$`se_data/se_2021`)

co <- as.data.frame(table(c(a, b, c))) %>% 
  filter(Freq == 3) %>% 
  mutate(Var1 = as.character(Var1)) %>% 
  .$Var1

nameandID <- list_of_dfs$`rawdata/MTeamSpellings.csv` %>% 

  mutate(sp = str_remove_all(TeamNameSpelling, "[^a-zA-Z0-9]")) %>% 
  left_join(list_of_dfs$`rawdata/MTeamConferences.csv`, by = "TeamID") %>%
  # lets assume there were no major conference changes from '19-'21
  filter(Season == 2019) %>% 
  select(-Season) 

team_stats <- sapply(stats, selector) %>% 
  bind_rows(.id = "id") %>% 
  select(-contains("opp"), -`REB MAR`, -ORebs, -DRebs, -TOPG) %>% 
  mutate(season = str_extract(id,"([0-9]+).*$"), .before = id) %>% 
  janitor::clean_names() %>% 
  relocate(team, .before = season) %>% 
  mutate(team = str_remove_all(tolower(team), "(?=\\().*?(?<=\\))"),
         team = str_remove_all(team, "[[:punct:] ]+")) %>% 
  left_join(nameandID, by = c("team" = "sp")) %>% 
  # Drops 8 teams, all with W-L ratios < .5
  drop_na() %>% 
  mutate(TeamID = as.character(TeamID)) %>% 
  tibble()
# Here is complete df of team stats from 2019 to 2021

team_stats

statoutcome <- seasionsoutcomes %>% 
  # this is where we lose 2021
  left_join(team_stats, by = c('TeamID', 'season')) %>% 
  drop_na() %>% 
  select(-TeamNameSpelling) %>% 
  mutate(opposing = if_else(TeamID == W, L, W), .after = TeamID, 
         opposing = as.character(opposing))

opposing_stats <- team_stats %>% 
  tibble() %>% 
  rename_at(vars(-season), ~paste0("opposing",.)) %>% 
  rename(opposing = opposingTeamID)

conf <- list_of_dfs$`rawdata/MTeamConferences.csv` %>% 
  filter(Season == 2019) %>% 
    mutate(TeamID = as.character(TeamID)) 

statoutcome %>% 
  left_join(opposing_stats, by = c('opposing', 'season')) %>% 
  left_join(conf, by = "TeamID") %>%
  # let's assume there were no major conference changes from '19-'21
  select(-ConfAbbrev.y, Season) %>% 
  rename(ConfAbbrev = ConfAbbrev.x) %>% 
  janitor::clean_names() %>% 
  distinct() %>% 
  mutate(team_score = ifelse(win == 1, w_score, l_score)) %>% 
  readr::write_csv(here::here("data", "merged.csv"))

merged <- readr::read_csv(here::here("data", "merged.csv"))

merged %>% 
  skimr::skim()


# bracket no pockets ------------------------------------------------------

begining_bracket <- readxl::read_excel(here::here("data", "begining_bracket.xlsx"))
team_names <- readr::read_csv(here::here("rawdata", "MTeamSpellings.csv"))

begining_bracket <- begining_bracket %>% 
  select(2, 35) %>% 
  stack() %>% 
  drop_na() %>% 
  tibble() %>% 
  rename(team = values) %>% 
  mutate(team = tolower(team)) %>% 
  mutate(game = 1:n(),
         game = as.numeric(game),
         otherteam  = if_else(game %% 2 == 1, team, lag(team)),
         game = if_else(game %% 2 == 1, game + 1, game), .before = team) %>% 
  filter(team != otherteam) %>% 
  filter(otherteam != "first round") %>% 
  left_join(team_names, by = c("team" = "TeamNameSpelling")) %>% 
  rename(teamid = TeamID) %>% 
  left_join(team_names, by = c("otherteam" = "TeamNameSpelling")) %>%
  rename(otherteamid = TeamID) %>% 
  mutate(teamid = replace(teamid, team == "app st.", 1111)) %>% 
  mutate_if(is.numeric, as.character) %>% 
  select(-ind, -game)

begining_bracket

# 2021 stats --------------------------------------------------------------



s2021 <- team_stats %>% 
  filter(season == 2021, 
         TeamID %in% c(begining_bracket$teamid, begining_bracket$otherteamid)) %>% 
  distinct(TeamID, .keep_all = TRUE) %>% 
  select(-season)


# logsitic fit ------------------------------------------------------------

logistic_fit <- glm(win ~ x3fg +
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

