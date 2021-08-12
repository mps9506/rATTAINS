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


x1 %>%
  enter_object("items") %>%
  gather_array() %>%
  spread_values(organizationIdentifier = jstring("organizationIdentifier"),
                organizationName = jstring("organizationName"),
                organizationTypeText = jstring("organizationTypeText")) %>%
  select(-c(.data$document.id, .data$array.index)) %>%
  enter_object("surveys") %>%
  gather_array() %>%
  spread_values(surveyStatusCode = jstring("surveyStatusCode"),
                year = jnumber("year"),
                surveyCommentText = jstring("surveyCommentText")) %>%
  select(-c(.data$array.index)) %>%
  enter_object("surveyWaterGroups") %>%
  gather_array() %>%
  spread_values(waterTypeGroupCode = jstring("waterTypeGroupCode"),
                subPopulationCode = jstring("subPopulationCode"),
                unitCode = jstring("unitCode"),
                size = jnumber("size"),
                siteNumber = jstring("siteNumber"),
                surveyWaterGroupCommentText = jstring("surveyWaterGRoupCommentText")) %>%
  select(-c(.data$array.index)) %>%
  enter_object("surveyWaterGroupUseParameters") %>%
  gather_array() %>%
  spread_values(stressor = jstring("stressor"),
                surveyUseCode = jstring("surveyUseCode"),
                surveyCategoryCode = jstring("surveyCategoryCode"),
                statistic = jstring("statistic"),
                metricValue = jnumber("metricValue"),
                confidenceLevel = jnumber("confidenceLevel"),
                commentText = jstring("commentText")) %>%
  select(-c(.data$array.index)) %>%
  as_tibble() %>%
  clean_names() -> content_surveys

x1 %>%
  enter_object("items") %>%
  gather_array() %>%
  spread_values(organizationIdentifier = jstring("organizationIdentifier"),
                organizationName = jstring("organizationName"),
                organizationTypeText = jstring("organizationTypeText")) %>%
  select(-c(.data$document.id, .data$array.index)) %>%
  enter_object("surveys") %>%
  gather_array() %>%
  spread_values(surveyStatusCode = jstring("surveyStatusCode"),
                year = jnumber("year"),
                surveyCommentText = jstring("surveyCommentText")) %>%
  select(-c(.data$array.index)) %>%
  enter_object("documents") %>%
  gather_array() %>%
  spread_values(agencyCode = jstring("agencyCode"),
                documentFileType = jstring("documentFileType"),
                documentFileName = jstring("documentFileName"),
                documentDescription = jstring("documentDescription"),
                documentComments = jstring("documentComments"),
                documentURL = jstring("documentURL")) %>%
  select(-c(.data$array.index)) %>%
  enter_object("documentTypes") %>%
  gather_array() %>%
  spread_all %>%
  select(-c(.data$array.index)) %>%
  as_tibble() %>%
  clean_names() -> content_documents
