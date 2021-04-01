# March-Madness

## Timeline
| date | goal | Progress|
| ---- | ---- | --- |
| 3/15 | The whole dataset combined and a model | Data is clean |
| 3/20 | get our model | model is complete |
| 3/28 |Need method for prediction| Function to predict outcome is written |
| 3/29 |Need to fill out a whole bracket | Bracket filled out |
| 3/31 | meet prof | check |
| 4/02 | run poison and multinom |
| 4/05 | Test performance against, random chance, seeds, and odds. ||
| 4/05 | recipes::step_normalize() compare outcome |
|4/05|outline paper|
| 4/05 |  Game finals played |
| 4/10 | proposal due |
| 4/12 | Write paper |
| 4/19 | Due  |
## Questions:

Can we make a predictive model for the upcoming March Madness Tournament.

### First Round Predcitons
![](https://i.imgur.com/KG9rI9z.png)
### Second Round Prediction
![](https://i.imgur.com/0xgl8nh.png)
### Third Round Predictions
![](https://i.imgur.com/mEuNcPl.png)

### Filled out bracket
![](https://i.imgur.com/dCyHFlc.png)


### scoring

assing score of pred_winner - pred_loser. sum it up and compare to 0.

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
