# Set up and get the csv file
# Note that "dplyr" package is used
# install.packages("dplyr)
rm(list = ls())
library(dplyr)
file = read.csv("all_stocks_5yr.csv")
data = data.frame(file)


# Clean data, here I drop all stock with less than 1259 valid observations
data$mid = (data$open + data$close) / 2
count = count(data, Name)
count = count[count$n != 1259,]
data = subset(data, !Name%in%count$Name)
na_col = unique(which(is.na(data), arr.ind=TRUE)[, 1])
data = data[!data$Name %in% data[na_col, ]$Name, ]


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
  return[, col] = log(price[2:nrow(price), col]/price[1:nrow(price) - 1, col])
}


# Get mean and covariance matrix of return
return_mean = colMeans(return)
return_cov = cov(return)
n = length(return_mean)


# Calculate minimum variance portfolio for each return
# Formula is derived by solving the matrix form Lagrangian
store = matrix(nrow=1000, ncol=2)
colnames(store) = c("Return", "Variance")
for (i in seq(1,1000)) {
  target = 0.0001 + (i - 1) * 0.00001
  A1 = cbind(return_cov, return_mean, rep(1, n))
  A2 = cbind(t(return_mean), 0, 0)
  A3 = cbind(t(rep(1,n)), 0, 0)
  A = rbind(A1, A2, A3)
  b = c(rep(0,n), target, 1)
  x = solve(A)%*%b
  var = t(x[1:n])%*%return_cov%*%x[1:n]
  store[i, 1] = target
  store[i, 2] = sqrt(var)
}


# Plot
plot(store[,2],store[,1],xlab = "Variance", ylab = "Return")




