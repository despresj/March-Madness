library(tidymodels)

merged <- readr::read_csv(here::here("data", "merged.csv"))

# Model Selection ---------------------------------------------------------------


# Best Subsets ------------------------------------------------------------

preds <- merged %>%
  select(x3fg:w) %>% 
  names()

varcombiner <- function(vars, outcome){
  models <- list()
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
  readr::write_csv(here::here("data", "bss.csv"))


# predictions -------------------------------------------------------------

