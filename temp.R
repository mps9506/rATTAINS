library(rATTAINS)
## errors
x<- assessment_units(state_code = "VA")

x<- assessment_units(state_code = "AL", tidy = FALSE)


library(tidyjson)
library(dplyr)
library(tidyr)
library(tibble)
library(purrr)


x <- actions(organization_id = "TCEQMAIN", tidy = FALSE)
x <- actions(action_id = "R8-ND-2018-03")


x <- domain_values(domain_name = "OrgStateCode")


x <- huc12_summary(huc = "020700100204", tidy = FALSE)

x <- plans(huc = "020700100204")

x <- surveys(organization_id = "SDDENR", tidy = "yes")



x1 <- actions(action_id = "R8-ND-2018-03")
