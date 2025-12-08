library(rATTAINS)
library(tidyr)
library(tibble)
library(dplyr)


x <- domain_values(tidy=FALSE) 
x <- jsonlite::fromJSON(x,
  simplifyVector = TRUE,
  simplifyDataFrame = TRUE,
  flatten = FALSE)

as_tibble(x)
