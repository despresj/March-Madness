library(tidyverse)
# options(tibble.print_max = 10, tibble.print_min = 30) 
list_of_dfs <- sapply(paste0("data/", dir("data")), read_csv, USE.NAMES = TRUE)