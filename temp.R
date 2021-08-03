library(rATTAINS)
## errors
x<- assessment_units(state_code = "TX")

x<- assessment_units(state_code = "AL")


library(tidyjson)
library(dplyr)
library(tidyr)
library(tibble)
library(purrr)

x %>%
  spread_all()

x %>%
  gather_object %>%
  json_types

x %>%
  enter_object(items) %>%
  gather_array %>%
  spread_all %>%
  gather_object() %>%
  json_types()


x %>%
  json_schema() -> schema

## need locations and water types, but locations dropped in the TX example since empty
## possible solution: https://github.com/colearendt/tidyjson/issues/117#issuecomment-650865347
## https://stackoverflow.com/questions/56662340/how-to-deal-with-nested-empty-json-arrays-with-tidyjson-in-r
x %>%
  enter_object(items) %>%
  gather_array() %>%
  spread_all() %>%
  select(-c(document.id,array.index)) %>%
  enter_object(assessmentUnits) %>%
  gather_array() %>%
  spread_all(recursive = TRUE) %>%
  select(-array.index) %>%
  ## this is slow as heck
  ## but not sure how to consistently return empty lists
  ## without errors.
  mutate(
    locations = purrr::map(..JSON, ~{
      .x[["locations"]] %>% {
        tibble(
          locationTypeCode = map(., "locationTypeCode"),
          locationText = map(., "locationText")
          )} %>%
        janitor::clean_names()
      }),
    waterTypes = purrr::map(..JSON, ~{
      .x[["waterTypes"]] %>% {
        tibble(
          waterTypeCode = map(., "waterTypeCode"),
          waterSizeNumber = map(., "waterSizeNumber"),
          unitsCode = map(., "unitsCode"),
          sizeEstimationMethod = map(., "SizeEstimationMethod"),
          sizeSourceText = map(., "sizeSourceText"),
          sizeSourceScaleText = map(., "sizeSourceScaleText")
        )} %>%
        janitor::clean_names()
    })
    ) -> temp2





jsonlite::fromJSON(x, simplifyVector = FALSE)$items %>%
    enframe() %>%
    select(-.data$name) %>%
    unnest_wider(.data$value, simplify = FALSE) %>%
    unnest_longer(.data$assessmentUnits, simplify = FALSE) %>%
    unnest_wider(.data$assessmentUnits, simplify = FALSE) %>%
    unnest_longer(.data$waterTypes) %>%
    unnest_wider(.data$waterTypes)


parsed_x <- jsonlite::fromJSON(x, simplifyVector = FALSE)$items

## https://stackoverflow.com/questions/63786411/how-to-unnest-wider-with-loop-over-all-the-columns-containing-lists

parsed_x %>%
  enframe() %>%
  select(-.data$name) %>%
  unnest_wider(.data$value) %>%
  unnest_longer(.data$assessmentUnits, simplify = FALSE) %>%
  unnest_wider(.data$assessmentUnits, simplify = FALSE) %>%
  purrr::keep(is.list) %>%
  purrr::discard(~any(purrr::map_lgl(., is_empty))) %>%
  names() -> names


