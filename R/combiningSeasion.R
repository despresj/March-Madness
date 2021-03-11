source(here::here("R", "ReadIn.R"))

seasion <- list_of_dfs$`data/MRegularSeasonDetailedResults.csv` %>% 
  left_join( list_of_dfs$`data/MTeams.csv`, by = c("WTeamID" = "TeamID")) %>% 
  select(-ends_with("Season")) %>% 
  rename(WTeamName = TeamName) %>% 
  left_join( list_of_dfs$`data/MTeams.csv`, by = c("LTeamID" = "TeamID")) %>% 
  rename(LTeamName = TeamName,
         Winfieldgoalsmade = WFGM,
         Winfieldgoalsattempted = WFGA,
         Winthreepointersmade = WFGM3,
         Winthreepointersattempted = WFGA3,
         Winfreethrowsmade = WFTM,
         Winfreethrowsattempted = WFTA,
         Winoffensiverebounds = WOR,
         Windefensiverebounds = WDR,
         Winassists = WAst,
         Winturnoverscommitted = WTO,
         Winsteals = WStl,
         Winblocks = WBlk,
         Winpersonalfoulscommitted = WPF,
         Lfieldgoalsmade = LFGM,
         Lfieldgoalsattempted = LFGA,
         Lthreepointersmade = LFGM3,
         Lthreepointersattempted = LFGA3,
         Lfreethrowsmade = LFTM,
         Lfreethrowsattempted = LFTA,
         Loffensiverebounds = LOR,
         Ldefensiverebounds = LDR,
         Lassists = LAst,
         Lturnoverscommitted = LTO,
         Lsteals = LStl,
         Lblocks = LBlk,
         Lpersonalfoulscommitted = LPF
  ) %>%
  relocate(LTeamName, .after = LTeamID) %>% 
  relocate(WTeamName, .after = WTeamID) %>% 
  mutate(diff = (Winfieldgoalsmade - Lfieldgoalsmade),
         std_dif = diff / sd(diff))



seasion %>%
  left_join(list_of_dfs$`data/MTeamConferences.csv`, by = c("WTeamID" = "TeamID")) %>%
  filter(Season == 2019) %>%
  unique()

hist(seasion$std_dif, breaks = 100)
hist(seasion$diff, breaks = 100)
mean(seasion$diff)
var(seasion$diff)

mean(seasion$WScore)
var(seasion$WScore)

hist(seasion$WScore, breaks = 100)

hist(rgamma(1000, 5, 3), breaks = 100)


preds <- seasion %>% 
  select(9:35) %>% 
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
  lm(x, data = seasion)
}

models <- varcombiner(vars = preds, outcome = "std_dif")


best_subsets_model <- map(models, logistic) %>% 
  map(glance) %>% 
  setNames(models) %>% 
  bind_rows(.id = "id") %>% 
  distinct() %>% 
  rename(model = id) %>% 
  slice_min(AIC) %>% 
  select(model)

best_subsets_model
