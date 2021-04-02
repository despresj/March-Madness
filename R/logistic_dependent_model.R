source(here::here("R", 'cleaningScript.R'))
source(here::here("R", "helper_functions.R"))
theme_set(theme_test())
options(tibble.print_min = 38)

# merged <- readr::read_csv(here::here("data", "merged.csv"))

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

# First round -------------------------------------------------------------

begining_bracket

probs <- map2_dbl(.x = begining_bracket$teamid, 
                  .y = begining_bracket$otherteamid, 
                  .f = logistic_predictor)


begining_bracket <- add_probs(begining_bracket, probs = probs)

nice_format(begining_bracket)

# second round ------------------------------------------------------------

second_round  <- advance_round(begining_bracket)

second_round_games <- align_teams(second_round)

probs <- map2_dbl(.x = second_round_games$teamid, 
                  .y = second_round_games$otherteamid, 
                  .f = logistic_predictor)

second_round <- add_probs(second_round_games, probs)

nice_format(second_round)

# sweet sixteen -------------------------------------------------------------

sweet_sixteen <- advance_round(second_round)

sweet_sixteen_games <- align_teams(sweet_sixteen)

sweet_sixteen_probs <- map2_dbl(.x = sweet_sixteen_games$teamid, 
                                .y = sweet_sixteen_games$otherteamid, 
                                .f = logistic_predictor)

sweet_sixteen_prediction <- add_probs(sweet_sixteen_games, probs = sweet_sixteen_probs)

nice_format(sweet_sixteen_prediction)


# elite eight -------------------------------------------------------------

elite_eight <- advance_round(sweet_sixteen_prediction)

elite_eight_games <- align_teams(elite_eight)

elite_eight_probs <- map2_dbl(.x = elite_eight_games$teamid, 
                                .y = elite_eight_games$otherteamid, 
                                .f = logistic_predictor)

elite_eight_prediction <- add_probs(elite_eight_games, elite_eight_probs)

nice_format(elite_eight_prediction)


# final four --------------------------------------------------------------

final_four <- advance_round(elite_eight_prediction)

final_four_games <- align_teams(final_four)

final_four_probs <- map2_dbl(.x = final_four_games$teamid, 
                             .y = final_four_games$otherteamid, 
                             .f = logistic_predictor)

final_four_prediction <- add_probs(final_four_games, final_four_probs)

nice_format(final_four_prediction)


# championship ------------------------------------------------------------

championship <- advance_round(final_four_prediction)

championship_game <- align_teams(championship)

championship_probs <- map2_dbl(.x = championship_game$teamid, 
                               .y = championship_game$otherteamid, 
                               .f = logistic_predictor)

championship_prediction  <- add_probs(championship_game, championship_probs)

nice_format(championship_prediction)
