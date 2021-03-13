library(tidymodels)

merged <- readr::read_csv(here::here("data", "merged"))


# Modeling. ---------------------------------------------------------------

formula <- merged %>% 
  select_if(is.numeric) %>% 
  select(-win) %>% 
  colnames() %>% 
  paste(collapse = " + ") %>% 
  paste("win ~", .)

formula

logistic_fit <- glm(formula = formula, data = merged,
                    family = binomial(link = logit))
logistic_fit %>% 
  tidy(conf.int = TRUE) %>% 
  mutate(`exp(estimate)` = exp(estimate)) %>% 
  relocate(`exp(estimate)`, .after = estimate)



merged %>%
  filter(team == "Michigan", opo_Team == "Michigan St")


predict.glm(logistic_fit, , type = "response")
