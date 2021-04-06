
# Scrape finals scores ----------------------------------------------------

library(rvest)
library(dplyr)

options(tibble.print_max = 50, tibble.print_min = 50)

url <- "https://www.ncaa.com/march-madness-live/scores"

scraped_final_scores <- read_html(url) %>% 
  html_nodes('.lvp') %>% 
  html_text(trim = TRUE)

scraped_final_scores[1:300]

games  <- tibble::tibble(scraped_final_scores[12:279]) %>% 
    rename(game = 1) %>% 
  mutate(id = rep(c("a", "b"), 268/2)) # this will break when game is done

spliter <- function(df, tag){
  df  %>% 
    filter(id == tag)
}

a <- spliter(games, "a")
b <- spliter(games, "b")

MTeamSpellings <- readr::read_csv("rawdata/MTeamSpellings.csv") %>% 
  mutate(TeamID = as.character(TeamID), 
           team = TeamNameSpelling)

scores <- bind_cols(a, b) %>% 
  select(1, 3) %>% 
  rename(team = 1, score = 2) %>% 
  mutate(team = stringr::str_to_lower(team)) %>% 
  left_join(MTeamSpellings, by = "team") %>% 
  select(1, 2, 4) %>% 
  mutate(id = rep(c("a", "b"), 134/2)) # this will break when game is done
  
a <- spliter(scores, "a")
b <- spliter(scores, "b")

bind_cols(a, b) %>% 
  rename(team = 1, 
            otherteam = 5,
            teamscore = 2, 
            otherteamscore = 6, 
            teamid = 3, 
         otherteamid = 7) %>% 
  select(1:3, 5:7) %>% 
  mutate(game = paste0(team, " vs ", otherteam),
         winner = if_else(teamscore > otherteamscore, team, otherteam)) %>% 
  select(game, winner, teamscore, otherteamscore) %>%
  readr::write_csv(here::here("data", "results.csv"))
  
