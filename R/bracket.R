library(tidyverse)

bracket <- readxl::read_excel(here::here("rawdata", "prebracket.xlsx"))

bracket <- bracket %>% 
  select(2, 35)
  
colnames(bracket) <- c("x1", "x2")

stack(bracket) %>% 
  select(values) %>% 
  drop_na() %>% 
  tibble() %>% 
  rename(team = values) %>% 
  mutate(game = 1:n(),
         game = as.numeric(game),
         otherteam  = if_else(game %% 2 == 1, team, lag(team)),
         game = if_else(game %% 2 == 1, game + 1, game), .before = team) %>% 
  filter(team != otherteam)
  
