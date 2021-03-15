library(tidyverse)

bracket <- readxl::read_excel(here::here("rawdata", "prebracket.xlsx"))

bracket <- bracket %>% 
  select(2, 35)
  
colnames(bracket) <- c("x1", "x2")


stack(bracket) %>% 
  select(values) %>% 
  drop_na() %>% 
  tibble() %>% 
  mutate(game = 1:n(),
         game = as.numeric(game),
         game = if_else(game %% 2 == 1, game + 1, game),
        team = values) 
