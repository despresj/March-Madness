library(tidyverse)
# https://plexkits.com/march-madness-bracket/ I think this will update
# https://docs.google.com/spreadsheets/d/1zaWZ2Xh7sll-PZKA1DhKvS6TdfE0Yggk0m5OWY4aICc/edit#gid=0

team_names <- readr::read_csv(here::here("rawdata", "MTeamSpellings.csv"))
bracket <- readxl::read_excel(here::here("data", "prebracket.xlsx"))

begining_bracket <- readxl::read_excel(here::here("data", "begining_bracket.xlsx"))


# Even better
# bracket <- googlesheets4::read_sheet("https://docs.google.com/spreadsheets/d/1zaWZ2Xh7sll-PZKA1DhKvS6TdfE0Yggk0m5OWY4aICc/edit#gid=0")
# remember API times out...

bracket <- bracket %>% 
  select(2, 35)
  
colnames(bracket) <- c("x1", "x2")


# bracket -----------------------------------------------------------------


bracket <- stack(bracket) %>% 
  select(values) %>% 
  drop_na() %>% 
  tibble() %>% 
  rename(team = values) %>% 
  mutate(team = tolower(team)) %>% 
  mutate(game = 1:n(),
         game = as.numeric(game),
         otherteam  = if_else(game %% 2 == 1, team, lag(team)),
         game = if_else(game %% 2 == 1, game + 1, game), .before = team) %>% 
  filter(team != otherteam) %>% 
  separate(team, into = c("team", "pocket"), "/") %>% 
  filter(otherteam != "first round") %>% 
  left_join(team_names, by = c("team" = "TeamNameSpelling")) %>% 
  rename(teamid = TeamID) %>% 
  left_join(team_names, by = c("otherteam" = "TeamNameSpelling")) %>%
  rename(otherteamid = TeamID) %>% 
  mutate(teamid = replace(teamid, team == "app st.", 1111)) %>% 
  mutate_if(is.numeric, as.character)

bracket

# pockets -----------------------------------------------------------------

pocket <- bracket %>% 
  select(team, pocket) %>% 
  drop_na() %>% 
  left_join(team_names, by = c("team" = "TeamNameSpelling")) %>% 
  rename(teamid = TeamID, otherteam = pocket) %>% 
  left_join(team_names, by = c("otherteam" = "TeamNameSpelling")) %>%
  rename(otherteamid = TeamID) %>% 
  mutate(otherteamid = replace(otherteamid, otherteam == "app st.", 1111)) %>% 
  relocate(ends_with("id"), .after = everything())

pocket

bracket <- bracket %>% 
  select(-game, -pocket)

bracket


# begining bracket (no pockets) -------------------------------------------

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
  