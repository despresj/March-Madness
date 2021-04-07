library(tidymodels)


logistic_predictions <- readRDS(here::here("cache", "logistic_predictions.RDS"))

posson_prediction <- readRDS(here::here("cache", "posson_prediction.RDS"))

multinom_prediction <- readRDS(here::here("cache", "multinom_prediction.RDS"))

results <- read_csv(here::here("data", "data/results.csv"))
