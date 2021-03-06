library(tidyverse)

list_of_dfs <- sapply(paste0("rawdata/", dir("rawdata")), read_csv, USE.NAMES = TRUE)

# https://www.kaggle.com/c/ncaam-march-mania-2021/data
lapply(list_of_dfs, colnames)
lapply(list_of_dfs, glimpse)

# Keys --------------------------------------------------------------------
# give us info about the data

list_of_dfs$`rawdata/MSeasons.csv`
# identifies the different seasons included in the historical data, 
# along with certain season-level properties.

list_of_dfs$`rawdata/MTeams.csv` # JOINED
# identifies the id number of the team

list_of_dfs$`rawdata/MTeamConferences.csv`
# indicates the conference affiliations for 
# each team during each season. 

list_of_dfs$`rawdata/MTeamCoaches.csv`
# indicates the head coach for each team in each season

list_of_dfs$`rawdata/MNCAATourneySlots.csv`
# bracket positions

list_of_dfs$`rawdata/MNCAATourneySeedRoundSlots.csv`
# seeds with slot and day and late

list_of_dfs$`rawdata/MMasseyOrdinals.csv` 
# lists out team rankings 

list_of_dfs$`rawdata/Conferences.csv`
# indicates the Division I conferences

list_of_dfs$`rawdata/MTeamSpellings.csv`
# indicates alternative spellings of many team names.

list_of_dfs$`rawdata/Cities.csv`
# This file provides a master list of cities that have
# been locations for games played.

# Data --------------------------------------------------------------------
# This is information about games played

list_of_dfs$`rawdata/MNCAATourneyDetailedResults.csv`
# provides team-level box scores for many NCAA® tournaments

list_of_dfs$`rawdata/MNCAATourneyCompactResults.csv`
#identifies the game-by-game NCAA® tournament results 
#for all seasons of historical data.

list_of_dfs$`rawdata/MRegularSeasonDetailedResults.csv`
# provides team-level box scores for many regular seasons 
# of historical data, starting with the 2003 season. 

list_of_dfs$`rawdata/MRegularSeasonCompactResults.csv`
# identifies the game-by-game results for many 
# seasons of historical data, starting with the 1985 season 

# Probally not useful -----------------------------------------------------
# For files I dont think well need but dont know yet

list_of_dfs$`rawdata/MSecondaryTourneyTeams.csv`
# identifies the teams that participated in post-season 
# tournaments other than the NCAA®

list_of_dfs$`rawdata/MSecondaryTourneyCompactResults.csv`
# indicates the final scores for the tournament games of 
# "secondary" post-season tournaments: the NIT, CBI, CIT, and Vegas 16. 

list_of_dfs$`rawdata/MConferenceTourneyGames.csv` #
# indicates which games were part of each year's post-season 
# conference tournaments (all of which finished on Selection Sunday or earlier

