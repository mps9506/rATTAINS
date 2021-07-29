library(rATTAINS)
## errors
x<- actions(state_code = "AL", summarize = TRUE)


#this works :eyeroll:
x <- actions(organization_id = "TCEQMAIN")


library(tidyjson)


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
  json_schema() -> actions_schema

## returns data for actions by assessment unit and pollutant
x %>%
  enter_object(items) %>%
  gather_array() %>%
  spread_all() %>%
  select(-array.index) %>%
  enter_object(actions) %>%
  gather_array() %>%
  spread_all() %>%
  select(-array.index) %>%
  enter_object(associatedWaters) %>%
  enter_object(specificWaters) %>%
  gather_array() %>%
  spread_all() %>%
  select(-array.index) %>%
  enter_object(associatedPollutants) %>%
  gather_array() %>%
  spread_all(recursive = TRUE) %>%
  select(-c(document.id, array.index)) %>%
  as_tibble()-> temp

## returns information about documents associated with returned actions
x %>%
  enter_object(items) %>%
  gather_array() %>%
  spread_all() %>%
  select(-c(array.index, document.id)) %>%
  enter_object(actions) %>%
  gather_array() %>%
  spread_all() %>%
  select(-c(array.index)) %>%
  dplyr::rename(agencyCode_1 = agencyCode) %>%
  enter_object(documents) %>%
  gather_array() %>%
  spread_all() %>%
  select(-c(array.index)) %>%
  enter_object(documentTypes) %>%
  gather_array() %>%
  spread_all(recursive = TRUE) %>%
  select(-c(array.index)) %>%
  as_tibble()-> temp
  # gather_keys() %>%
  # select(key)

## returns the count of unique actions
x %>%
  spread_all() %>%
  select(count) %>%
  as_tibble()

## if summarise is true returns the count of assessment units for the action
x %>%
  enter_object(items) %>%
  gather_array() %>%
  spread_all() %>%
  select(-c(array.index, document.id)) %>%
  enter_object(actions) %>%
  gather_array() %>%
  spread_all(recursive = TRUE) %>%
  select(-c(array.index)) %>%
  as_tibble()-> temp
