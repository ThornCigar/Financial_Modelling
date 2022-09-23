# Copyright (C) 2022 ThornCigar, All Rights Reserved.
#
# https://github.com/ThornCigar
#

library(dplyr)


# Clear the environment
rm(list = ls())


# Import data
data = read.csv("all_stocks_5yr.csv")


# Normalise data
## Remove data with inconsistent amount
data_count = count(data, Name)
data_count_count = count(count(data, Name), n)
data_count_target = data_count_count[order(-data_count_count$nn), ][1, "n"]
purge_list = data_count[data_count$n != data_count_target, ]
data = subset(data, !Name %in% purge_list$Name)

## Remove data with N/A entries
na_col = unique(which(is.na(data), arr.ind = TRUE)[, 1])
data = data[!data$Name %in% data[na_col, ]$Name, ]

## Add mid row
data$mid = (data$open + data$close) / 2

rm(data_count,
   data_count_count,
   data_count_target,
   purge_list,
   na_col)


# Extract estimated mid-day price (open plus close divided by 2) into matrix
price = matrix(nrow = 1259, ncol = 468) # Bad code here
row = 1
col = 0
i = 1
current = ""
while (i <= nrow(data)) {
  if (data[i, ]$Name != current) {
    current = data[i, ]$Name
    row = 1
    col = col + 1
  }
  price[row, col] = data[i, ]$mid
  row = row + 1
  i = i + 1
}


# Use log return for return matrix
return = matrix(nrow = nrow(price) - 1, ncol = ncol(price))
for (col in 1:ncol(return)) {
  return[, col] = log(price[2:nrow(price), col] / price[1:nrow(price) - 1, col])
}


# Get mean and covariance matrix of return
return_mean = colMeans(return)
return_cov = cov(return)
n = length(return_mean)


# Calculate minimum variance portfolio for each return
# Formula is derived by solving the matrix form Lagrangian
store = matrix(nrow = 1000, ncol = n + 2)
# colnames(store) = c("Weight 1", "Return", "SD")
for (i in seq(1, 1000)) {
  target = 0.0001 + (i - 1) * 0.00001
  A1 = cbind(return_cov, return_mean, rep(1, n))
  A2 = cbind(t(return_mean), 0, 0)
  A3 = cbind(t(rep(1, n)), 0, 0)
  A = rbind(A1, A2, A3)
  b = c(rep(0, n), target, 1)
  x = solve(A) %*% b
  # print(sum(x[1:n]))
  var = t(x[1:n]) %*% return_cov %*% x[1:n]
  store[i, 1:n] = x[1:n]
  store[i, n + 1] = target
  store[i, n + 2] = sqrt(var)
}


# Plot
plot(store[, n + 2], store[, n + 1], xlab = "SD", ylab = "Return")


# Testing linear combination of efficient portfolios
portfolio_1 = store[100, ]
portfolio_2 = store[nrow(store) - 100, ]
store2 = matrix(nrow = 10001, ncol = 2)
j = 1
for (i in seq(0, 1, 0.0001)) {
  weight = i * portfolio_1[1:n] + (1 - i) * portfolio_2[1:n]
  store2[j, 1] = t(weight) %*% return_mean
  var = t(weight) %*% return_cov %*% weight
  store2[j, 2] = sqrt(var)
  j = j + 1
}
plot(store2[, 2],
     store2[, 1],
     xlab = "SD",
     ylab = "Return",
     col = "blue")
lines(store[, n + 2], store[, n + 1], col = "red")
