df <- dl_state_summary(organization_id = "TCEQMAIN", reporting_cycle = "2014")

tibble::as_tibble(df$data$reportingCycles$waterTypes)
library(dplyr)
library(ggplot2)
library(purrr)
df[["data"]][["reportingCycles"]]$waterTypes %>%
  map_chr("waterTypeCode")


df <- df[["data"]][["reportingCycles"]]


df <- df %>%
  tidyr::unnest(waterTypes)

df <- df %>%
  tidyr::unnest(useAttainments)


df <- df %>%
  tidyr::unnest(parameters)


df %>%
  dplyr::filter(reportingCycle == "2014") -> df

df %>%
  dplyr::filter(waterTypeCode == "STREAM") -> df
