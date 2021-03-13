library(tidymodels)

merged <- readr::read_csv(here::here("data", "merged.csv"))

team_ <- readr::read_csv(here::here("data", "teamstat.csv"))
opo   <- readr::read_csv(here::here("data", "oposestat.csv"))


team_ %>% 
  filter(team_team == "michigan") 
  
opo %>% 
  filter(opo_TeamSp == "michiganst") 

merged

# Modeling. ---------------------------------------------------------------

formula <- merged %>% 
  select_if(is.numeric) %>% 
  select(-win, -TeamID, -oposingTeamID) %>% 
  colnames() %>% 
  # random for now
  sample(5) %>% 
  paste(collapse = " + ") %>% 
  paste("win ~", .)

formula

logistic_fit <- glm(formula = formula, data = merged,
                    family = binomial(link = logit))

modeltibble <- logistic_fit %>% 
  tidy(conf.int = TRUE) %>% 
  mutate(`exp(estimate)` = exp(estimate)) %>% 
  relocate(`exp(estimate)`, .after = estimate) %>% 
  mutate_if(is.numeric, round, 5)

pred <- modeltibble %>% 
  select(term) %>% 
  filter(term != "(Intercept)") %>% 
  bind_cols(pred = c(5, 3, 2, 4,5)) %>% 
  pivot_wider(names_from = term, values_from = pred)


predict.glm(logistic_fit, data.frame(pred), type = "response")

# TODO: we need a function that takes inputed game, and outputs a preiction

logistic_fit


predictor <- function (object, modeltibble, predvec) {
  tib <- modeltibble[1]
  tibs <- tib[2:6,]
  tibs <- cbind(tibs, predvec)
  reshape(tibs, direction = "wide")
  return(tibs)
}

modeltibble %>% 
  select(term)
debugonce(predictor)
predictor(logistic_fit, modeltibble = modeltibble, predvec = c(5, 3, 2, 4,5))
