library(tidymodels)
theme_set(theme_test())
source(here::here("R", "bracket.R"))
source(here::here("R", 'cleaningScript.R'))

# merged <- readr::read_csv(here::here("data", "merged.csv"))


# Take a look -------------------------------------------------------------


# model selection ---------------------------------------------------------

fit <- glm(win ~ x3fg +
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
summary(fit)

s2021 <- team_stats %>% 
  filter(season == 2021, 
         TeamID %in% c(bracket$teamid, bracket$otherteamid)) %>% 
  distinct(TeamID,.keep_all = TRUE )

# TODO: Need a predictor function.

preddat <- merged %>% 
  filter(season == 2020, 
         team %in% c(bracket$team, bracket$otherteam)) %>% 
  select(
    x3fg,
    opposingx3fg,
    fg_percent,
    opposingfg_percent,
    ft_percent,
    opposingft_percent,
    rpg,
    opposingrpg,
    st,
    opposingst,
    to,
    opposingto,
    opposingbkpg,
    bkpg)
