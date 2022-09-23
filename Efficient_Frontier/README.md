# Efficient_Frontier
R code for calculating the efficient frontier, sample data set used is taken from https://github.com/CNuge/kaggle-code/tree/master/stock_data
A verification of the two fund theorem is also provided.

## Getting started
On cloning the repository, simply open `Efficient_Frontier.Rproj` in RStudio.

Then, restore development environment by running `renv::restore()`.

## Developing the project
- This project leverages `renv`, which enables project-wide dependency management. Using it ensures development environment consistency and allows quick rollback of environments. Refer to the renv [introductory documentation](https://rstudio.github.io/renv/articles/renv.html) for more.

# To-Do List
## Port to python
- [ ] CSV to python, preserving column names, dataframe or numpy?
- [ ] Data wrangling
- [ ] Extract price (mid-day, close?) into matrix/dataframe
- [ ] Mean and covariance matrix for log return
- [ ] **Additional functionality, dynamic frontier, dynamic return and volatility, refer to "Additional"**
- [ ] Mean variance optimisation for efficient frontier
- [ ] Optimisation for capital allocation line, cash as risk-free/included in MVO process
- [ ] Verification of Two Fund Theorem
- [ ] Graphs

## Additional
- [ ] Dynamic frontier: Dynamic efficient frontier based on rolling-window, maybe extend data and allow for longer lookback period?
- [ ] Dynamic expected return and covariance implemented with GARCH/other methods? May required LASSO to reduce parameters estimated
- [ ] Reverse optimisation using simple market model (beta)
- [ ] Maybe try to implement Black-Litterman?
- [ ] Data acquisition, may not be possible, try Yahoo Finance API?

## General
- [ ] Learn to use version control god god god stop uploading manually
