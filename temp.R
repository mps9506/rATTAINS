library(rATTAINS)
library(tidyjson)
library(dplyr)
library(tidyr)
library(tibble)
library(purrr)
library(janitor)



x1 <- assessments(organization_id = "SDDENR", probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES", tidy = FALSE)
x1 <- assessments(state_code = "OR", exclude_assessments = TRUE, tidy = FALSE)
x1 <- assessments(state_code = "TX", tidy = TRUE)
x1 <- domain_values(domain_name="UseName",context="TDECWR",tidy = FALSE)
x1 <- huc12_summary(huc = "020700100204", tidy=FALSE)
x1 <- plans(huc ="020700100103", summarize = FALSE, tidy = FALSE)
x1 <- plans(huc ="020700100103", summarize = TRUE)
x1 <- state_summary(organization_id = "TCEQMAIN", tidy = FALSE)
x1 <- surveys(organization_id="SDDENR", tidy = FALSE)
x1 <- surveys(organization_id = "TCEQMAIN", tidy = FALSE)

assessments_cache$cache_path_get()
