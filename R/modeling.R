library(tidymodels)

merged <- readr::read_csv(here::here("data", "merged.csv"))

# Model Selection ---------------------------------------------------------------


# Best Subsets ------------------------------------------------------------

preds <- merged %>%
  select(x3fg:w) %>% 
  names()

varcombiner <- function(vars, outcome){
  models <- vector(mode = "list", length = 2^length(preds)-1)
  for (i in 1:length(vars)) {
    vc <- combn(vars,i)
    for (j in 1:ncol(vc)) {
      mod <- paste0(outcome, " ~ ", paste0(vc[,j], collapse = " + "))
      model <- as.formula(mod)
      models <- c(models, model)
    }
  }
  models
}

logistic <- function(x){
  glm(x, data = merged, family = "binomial")
}

models <- varcombiner(vars = preds, outcome = "win")

best_subsets_model <- map(models, logistic) %>% 
  map(glance) %>% 
  setNames(models) %>% 
  bind_rows(.id = "id") %>% 
  distinct()

best_subsets_model %>% 
  readr::write_csv("data", "bss.csv")


# predictions -------------------------------------------------------------


formula <- merged %>% 
  select_if(is.numeric) %>% 
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


