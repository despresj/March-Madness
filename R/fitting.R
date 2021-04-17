logistic_fit <- glm(win ~ x3fg +
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

logistic_fit_null <- glm(win ~ 1,
                    data = merged, family = "binomial") 

 fit_poisson <- glm(team_score ~ x3fg +
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
              data = merged, family = poisson(link = "log"))
 
 fit_multinom <- VGAM::vglm(x_tile ~ x3fg +
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
                  bkpg, family = VGAM::cumulative(parallel=TRUE),
                  data = merged)