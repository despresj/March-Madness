library(tidymodels)

source(here::here("R", "bracket.R"))
source(here::here("R", 'cleaningScript.R'))

merged <- readr::read_csv(here::here("data", "merged.csv"))




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

bracket$otherteam

# TODO: figure out what happened to 2021 data

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

pred <- merged %>% 
  filter(season == 2020, 
         team %in% c(bracket$team, bracket$otherteam))

cbind(
pred$team,
faraway::ilogit(predict(fit, preddat))
) %>% 
  tibble() %>% 
  distinct()

team <- team_stats %>% 
  tibble() %>% 
  filter(TeamID %in% pocket$teamid,
         season == 2020) %>%
  distinct(team, .keep_all = TRUE) %>% 
  select(
    x3fg,
    fg_percent,
    ft_percent,
    rpg,
    st,
    to,
    bkpg)

pocket$otherteam

opposing <- team_stats %>%
  tibble() %>% 
  filter(TeamID %in% pocket$otherteamid,
         season == 2020) %>% 
  distinct(TeamID, .keep_all = TRUE) %>% 
  select(
    x3fg,
    fg_percent,
    ft_percent,
    rpg,
    st,
    to,
    bkpg) %>% 
  rename_all( ~paste0("opposing",.))
  

# TODO: remember to come up with a better solution for this

opposing <- rbind(opposing, sapply(opposing, mean) )

team
opposing

bind_cols(team, opposing)

cbind(
pocket$team,
faraway::ilogit(predict(fit, bind_cols(team, opposing)))
)
