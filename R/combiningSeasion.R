source(here::here("R", "ReadIn.R"))



list_of_dfs$`data/MRegularSeasonDetailedResults.csv` %>% 
  left_join( list_of_dfs$`data/MTeams.csv`, by = c("WTeamID" = "TeamID")) %>% 
  select(-ends_with("Season")) %>% 
  rename(WTeamName = TeamName) %>% 
  left_join( list_of_dfs$`data/MTeams.csv`, by = c("LTeamID" = "TeamID")) %>% 
  rename(LTeamName = TeamName,
         Winfieldgoalsmade = WFGM  , 
         Winfieldgoalsattempted = WFGA  , 
         Winthreepointersmade = WFGM3 , 
         Winthreepointersattempted = WFGA3 , 
         Winfreethrowsmade = WFTM  , 
         Winfreethrowsattempted = WFTA  , 
         Winoffensiverebounds = WOR   ,
         Windefensiverebounds = WDR   ,
         Winassists = WAst  ,
         Winturnoverscommitted = WTO   ,
         Winsteals = WStl  ,
         Winblocks = WBlk  ,
         Winpersonalfoulscommitted = WPF   , 
         Lfieldgoalsmade = LFGM  , 
         Lfieldgoalsattempted = LFGA  , 
         Lthreepointersmade = LFGM3 , 
         Lthreepointersattempted = LFGA3 , 
         Lfreethrowsmade = LFTM  , 
         Lfreethrowsattempted = LFTA  , 
         Loffensiverebounds = LOR   ,
         Ldefensiverebounds = LDR   ,
         Lassists = LAst  ,
         Lturnoverscommitted = LTO   ,
         Lsteals = LStl  ,
         Lblocks = LBlk  ,
         Lpersonalfoulscommitted = LPF   
  ) %>% 
  relocate(LTeamName, .after = LTeamID) %>% 
  relocate(WTeamName, .after = WTeamID)