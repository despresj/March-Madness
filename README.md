# March-Madness

## Timeline
| date | goal | Progress|
| ---- | ---- | --- |
| 3/15 | The whole dataset combined and a model | :white_check_mark: Data is combined and clean  |
| 3/20 | Outline our model | :white_check_mark:  model outline is complete  |
| 3/28 |Need method for prediction| :white_check_mark:  Function to predict outcome works |
| 3/29 | Need to fill out a whole bracket | :white_check_mark:  Bracket filled out  |
| 3/31 | Consult with Prof |  :white_check_mark:  |
| 4/02 | Make pois and Multinom |  :white_check_mark:  |
| 4/05 | outline [Paper](https://github.com/despresj/March-Madness/blob/main/paper/paper.pdf)  |  :white_check_mark:  |
| 4/05 | Game finals played | :white_check_mark:  results [scraped](https://github.com/despresj/March-Madness/blob/main/R/scrape_finals.R) |
| 4/10 | [Proposal](https://github.com/despresj/March-Madness/blob/main/proposal/proposal.pdf) due | :white_check_mark: Done  |
| 4/10 | recipes::step_normalize() compare outcome | :white_check_mark: Not helpful|
| 4/10 | Test performance against, random chance, seeds, and odds. | :white_check_mark:  |
| 4/19 | [slides](https://github.com/despresj/March-Madness/blob/main/slides/slides.Rmd) due | :white_check_mark: Finished  |
| 4/16 | [draft Paper](https://github.com/despresj/March-Madness/blob/main/paper/paper.pdf) | |   :white_check_mark: draft finished |
| 4/24 | [Paper](https://github.com/despresj/March-Madness/blob/main/paper/paper.pdf) Due| |  :white_check_mark:   Finished!|
## Questions:

Can we make a predictive model for the upcoming March Madness Tournament.

### Model

![](/Users/josephdespres/Documents/MSU/MISC/STT-864_Statistical_Methods_II/March-Madness/slides/images/model.png)

### scoring

![](/Users/josephdespres/Documents/MSU/MISC/STT-864_Statistical_Methods_II/March-Madness/slides/images/scoring.png)

### Performance

![](/Users/josephdespres/Documents/MSU/MISC/STT-864_Statistical_Methods_II/March-Madness/slides/images/performance.png)


### First Round Predcitons
![](https://i.imgur.com/KG9rI9z.png)
### Second Round Prediction
![](https://i.imgur.com/0xgl8nh.png)
### Third Round Predictions
![](https://i.imgur.com/mEuNcPl.png)

### Filled out bracket
![](https://i.imgur.com/dCyHFlc.png)


# Datasets:
### Turniment game outcomes data
DayNum, WTeamID, WTeamName, WScore, LTeamID, LTeamName, LScore, WLoc, NumOT, Winfieldgoalsmade, Winfieldgoalsattempted, Winthreepointersmade, Winthreepointersattempted, Winfreethrowsmade, Winfreethrowsattempted, Winoffensiverebounds, Windefensiverebounds, Winassists, Winturnoverscommitted, Winsteals, Winblocks, Winpersonalfoulscommitted, Lfieldgoalsmade, Lfieldgoalsattempted, Lthreepointersmade, Lthreepointersattempted, Lfreethrowsmade, Lfreethrowsattempted, Loffensiverebounds, Ldefensiverebounds, Lassists, Lturnoverscommitted, Lsteals, Lblocks, Lpersonalfoulscommitted, FirstD1Season, LastD1Season"

### Seasion game outcomes data 
DayNum, WTeamID, WTeamName, WScore, LTeamID, LTeamName, LScore, WLoc, NumOT, Winfieldgoalsmade, Winfieldgoalsattempted, Winthreepointersmade, Winthreepointersattempted, Winfreethrowsmade, Winfreethrowsattempted, Winoffensiverebounds, Windefensiverebounds, Winassists, Winturnoverscommitted, Winsteals, Winblocks, Winpersonalfoulscommitted, Lfieldgoalsmade, Lfieldgoalsattempted, Lthreepointersmade, Lthreepointersattempted, Lfreethrowsmade, Lfreethrowsattempted, Loffensiverebounds, Ldefensiverebounds, Lassists, Lturnoverscommitted, Lsteals, Lblocks, Lpersonalfoulscommitted, FirstD1Season, LastD1Season

*Note same column names*
We can combine this into one df.

## Covariates:

## Hypothesis:

## Tests:

## Assumptions:

## results:

## Plots:

## Tables:

## Conclusion
