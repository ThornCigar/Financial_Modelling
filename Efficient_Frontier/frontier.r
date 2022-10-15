# Copyright (C) 2022 ThornCigar, All Rights Reserved.
#
# https://github.com/ThornCigar
#
# Special thanks to DragonXi for their contribution.


library(dplyr)
rm(list = ls()) # Clear the environment
data = read.csv("all_stocks_5yr.csv") # Import data


# normalise_data(data) -> data
#
# Normalises data and calculates "mid" prices.
# This function is fully idempotent.
normalise_data = function(data) {
  ## Remove data with inconsistent amount
  data_count = count(data, Name)
  data_count_count = count(count(data, Name), n)
  data_count_target = data_count_count[order(-data_count_count$nn), ][1, "n"]
  purge_list = data_count[data_count$n != data_count_target, ]
  data = subset(data, !Name %in% purge_list$Name)

  ## Remove data with N/A entries
  na_row = unique(which(is.na(data), arr.ind = TRUE)[, 1])
  data = data[!data$Name %in% data[na_row, ]$Name, ]

  ## Add "mid" column
  data$mid = (data$open + data$close) / 2

  return(data)
}


# get_return_matrix(price_mat) -> return_mat
#
# Uses log return to calculate return matrix from price matrix.
get_return_matrix = function(price_mat) {
  data_row_count = nrow(price_mat)
  data_col_count = ncol(price_mat)
  return_mat = matrix(nrow = data_row_count - 1, ncol = data_col_count)
  for (c in 1:data_col_count) {
    return_mat[, c] = log(price_mat[2:data_row_count, c] /
                            price_mat[1:data_row_count - 1, c])
  }
  return(return_mat)
}


# frontier(return) -> store
#
# Use return matrix to calculate efficient frontier, store weights, return and sd
frontier = function(return){
  return_mean = colMeans(return)
  return_cov = cov(return)
  n = length(return_mean)
  A1 = cbind(2 * return_cov, return_mean, rep(1, n))
  A2 = cbind(t(return_mean), 0, 0)
  A3 = cbind(t(rep(1, n)), 0, 0)
  A = rbind(A1, A2, A3)
  A_inv = solve(A)
  rm(A1, A2, A3)

  # Calculate minimum variance portfolio for each return
  # Formula is derived by solving the matrix form Lagrangian
  store = matrix(nrow = 1000, ncol = n + 2)
  # colnames(store) = c("Weight 1", "Return", "SD")
  for (i in seq(1, 1000)) {
    target = 0.0001 + (i - 1) * 0.00001
    b = c(rep(0, n), target, 1)
    x = A_inv %*% b
    var = t(x[1:n]) %*% return_cov %*% x[1:n]
    store[i, 1:n] = x[1:n]
    store[i, n + 1] = target
    store[i, n + 2] = sqrt(var)
  }
  return(store)
}


# Looking to functionise everything and hopefully remove this part later
data = normalise_data(data)
data_dim = count(data, Name) # unreliable stock name order
data_col_count = nrow(data_dim)
data_row_count = data_dim[1, 'n']


# Reshape 1d price vector into 2d price matrix
price_mat = matrix(data[["mid"]], nrow = data_row_count)
return_mat = get_return_matrix(price_mat)


# Calculate frontier and plot
store = frontier(return_mat)
plot(store[, data_col_count + 2], store[, data_col_count + 1], xlab = "SD", ylab = "Return")


# sliding(return, window, expand) -> store (3 dimensional)
#
# Sliding window implementation, singularity issue for small window to be fixed
sliding = function(return, window=502, expand=FALSE){
  n = ncol(return)
  store = array(dim=c(1000,n + 2, nrow(return) - window + 1))
  for (t in seq(1, nrow(return) - window + 1)) {
    return_slice = return[t:(t + window - 1), ]
    store[,,t] = frontier(return_slice)
  }
  return(store)
}


# test = sliding(return_mat)


## This part need to be re-written, but with very low priority
# Testing linear combination of efficient portfolios
# portfolio_1 = store[100, ]
# portfolio_2 = store[nrow(store) - 100, ]
# store2 = matrix(nrow = 10001, ncol = 2)
# j = 1
# for (i in seq(0, 1, 0.0001)) {
#   weight = i * portfolio_1[1:data_col_count] + (1 - i) * portfolio_2[1:data_col_count]
#   store2[j, 1] = t(weight) %*% return_mean
#   var = t(weight) %*% return_cov %*% weight
#   store2[j, 2] = sqrt(var)
#   j = j + 1
# }
#
# plot(store2[, 2],
#      store2[, 1],
#      xlab = "SD",
#      ylab = "Return",
#      col = "blue")
# lines(store[, data_col_count + 2], store[, data_col_count + 1], col = "red")
