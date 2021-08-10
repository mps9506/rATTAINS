library(rATTAINS)
library(tidyjson)
library(dplyr)
library(tidyr)
library(tibble)
library(purrr)
library(janitor)



x1 <- assessments(organization_id = "SDDENR", probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES", tidy = FALSE)
x1 <- assessments(state_code = "OR", exclude_assessments = TRUE, tidy = FALSE)
x1 <- assessments(state_code = "TX", exclude_assessments = TRUE, tidy = FALSE)



content <- content$items %>%
  tibble::enframe() %>%
  select(!c(.data$name)) %>%
  unnest_wider(.data$value) %>%
  unnest_longer(.data$documents) %>%
  unnest_wider(.data$documents) %>%
  unnest_longer(.data$documentTypes) %>%
  unnest_wider(.data$documentTypes) %>%
  janitor::clean_names()


x1 %>%
  enter_object("items") %>%
  gather_array() %>%
  spread_all() %>%
  select(-c(.data$array.index, .data$document.id)) %>%
  enter_object("documents") %>%
  gather_array() %>%
  spread_all(recursive = TRUE) %>%
  select(-c(.data$array.index)) %>%
  mutate(
    documentTypes = map(.data$..JSON, ~{
      .x[["documentTypes"]] %>% {
        tibble(
          assessmentTypeCode = map_chr(., "documentTypeCode")
        )}
    })) %>%
  tibble::as_tibble() %>%
  unnest(c(.data$documentTypes)) %>%
  janitor::clean_names()-> content_docs


x1 %>% gather_object() %>% filter(name == "count") %>% spread_values(count = jnumber()) %>% select(-c(document.id, name)) %>% as_tibble()
