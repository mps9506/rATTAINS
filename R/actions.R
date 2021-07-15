#' Download Actions Data
#'
#' Provides data about actions (TMDLs, 4B Actions, Alternative Actions, Protection Approach Actions) that have been finalized.
#'
#' @param action_id (character) specifies what action to retrieve. multiple values allowed. optional
#' @param assessment_unit_id (character)
#' @param state_code (character)
#' @param organization_id (character)
#' @param summarize (logical)
#' @param parameter_name (character)
#' @param pollutant_name (character)
#' @param action_type_code (character)
#' @param agency_code (character)
#' @param pollutant_source_code (character)
#' @param action_status_code (character)
#' @param completion_date_later_than (character)
#' @param completion_date_earlier_than (character)
#' @param tmdl_date_later_than (character)
#' @param tmdl_date_earlier_then (character)
#' @param last_change_later_than_date (character)
#' @param last_change_earlier_than_date (character)
#' @param return_count_only (logical)
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return tibble
#' @export
#' @importFrom dplyr mutate
#' @importFrom janitor clean_names
#' @importFrom jsonlite fromJSON
#' @importFrom purrr map possibly
#' @importFrom rlist list.filter
#' @importFrom rlang is_empty .data
#' @importFrom tibble enframe
#' @importFrom tidyr unnest_longer unnest_wider
actions <- function(action_id = NULL,
                    assessment_unit_id = NULL,
                    state_code = NULL,
                    organization_id = NULL,
                    summarize = FALSE,
                    parameter_name = NULL,
                    pollutant_name = NULL,
                    action_type_code = NULL,
                    agency_code = NULL,
                    pollutant_source_code = NULL,
                    action_status_code = NULL,
                    completion_date_later_than = NULL,
                    completion_date_earlier_than = NULL,
                    tmdl_date_later_than = NULL,
                    tmdl_date_earlier_then = NULL,
                    last_change_later_than_date = NULL,
                    last_change_earlier_than_date = NULL,
                    return_count_only = FALSE,
                    ...) {
  returnCountOnly <- if(isTRUE(return_count_only)) {
    "Y"
  } else {"N"}
  summarize <- if(isTRUE(summarize)) {
    "Y"
  } else {"N"}

  args <- list(actionIdentifier = action_id,
               assessmentUnitIdentifier = assessment_unit_id,
               stateCode = state_code,
               organizationIdentifier = organization_id,
               summarize = summarize,
               parameterName = parameter_name,
               pollutantName = pollutant_name,
               actionTypeCode = action_type_code,
               agencyCode = agency_code,
               pollutantSourceCode = pollutant_source_code,
               actionStatusCode = action_status_code,
               completionDateLaterThan = completion_date_later_than,
               completionDateEarlierThan = completion_date_earlier_than,
               tmdlDateLaterThan = tmdl_date_later_than,
               tmdlDateEarlierThan = tmdl_date_earlier_then,
               lastChangeLaterThanDate = last_change_later_than_date,
               lastChangeEarlierThanDate = last_change_earlier_than_date,
               returnCountOnly = returnCountOnly)
  args <- list.filter(args, !is.null(.data))
  required_args <- c("actionIdentifier",
                     "assessmentUnitIdentifier",
                     "stateCode",
                     "organizationIdentifier")
  args_present <- intersect(names(args), required_args)
  if(is_empty(args_present)) {
    stop("One of the following arguments must be provided: action_id, assessment_unit_id, state_code, or organization_id")
  }
  path = "attains-public/api/actions"
  content <- xGET(path, args, ...)
  content <- fromJSON(content, simplifyVector = FALSE)
  content <- actions_to_tibble(content,
                               count = returnCountOnly,
                               summarize = summarize)

  return(content)
}


actions_to_tibble <- function(content,
                  count = FALSE,
                  summarize = FALSE) {

  if(isTRUE(count)) {
    return(content$count)
  } else {
    if(isTRUE(summarize)) {
      content$items %>%
        tibble::enframe()  %>%
        select(!c(.data$name)) %>%
        unnest_wider(.data$value) %>%
        unnest_longer(.data$actions) %>%
        unnest_wider(.data$actions)  %>%
        select(-c(.data$agencyCode)) %>%
        unnest_longer(.data$documents) %>%
        unnest_wider(.data$documents) %>%
        unnest_longer(.data$documentTypes) %>%
        unnest_wider(.data$documentTypes) %>%
        unnest_wider(.data$TMDLReportDetails) %>%
        unnest_longer(.data$associatedPollutants) %>%
        unnest_wider(.data$associatedPollutants) %>%
        select(-c(.data$auCount)) %>%
        unnest_longer(.data$parameters) %>%
        unnest_wider(.data$parameters) %>%
        clean_names()-> content
      return(content)

    } else{
      content$items %>%
        tibble::enframe()  %>%
        select(!c(.data$name)) %>%
        unnest_wider(.data$value) %>%
        unnest_longer(.data$actions) %>%
        unnest_wider(.data$actions)  %>%
        select(-c(.data$associatedWaters, .data$agencyCode)) %>%
        unnest_longer(.data$documents) %>%
        unnest_wider(.data$documents) %>%
        unnest_longer(.data$documentTypes) %>%
        unnest_wider(.data$documentTypes) %>%
        unnest_wider(.data$TMDLReportDetails) %>%
        clean_names()-> content_docs

      content$items %>%
        tibble::enframe() %>%
        select(!c(.data$name)) %>%
        unnest_wider(.data$value) %>%
        unnest_longer(.data$actions) %>%
        unnest_wider(.data$actions) %>%
        select(-c(.data$documents, .data$agencyCode)) %>%
        unnest_wider(.data$associatedWaters) %>%
        unnest_longer(.data$specificWaters) %>%
        unnest_wider(.data$specificWaters) %>%
        unnest_longer(.data$associatedPollutants) %>%
        unnest_wider(.data$associatedPollutants) %>%
        mutate(completionDate = as.Date(.data$completionDate)) %>%
        unnest_longer(.data$loadAllocationDetails) %>%
        unnest_wider(.data$loadAllocationDetails) %>%
        mutate(permits = purrr::map(.data$permits,
                                    ~{
                                      tibble::enframe(.x) %>%
                                        select(-c(.data$name)) %>%
                                        unnest_wider(.data$value) %>%
                                        q_unnest_l(.data$details) %>%
                                        q_unnest_w(.data$details)
                                    })) %>%
        unnest_longer(.data$parameters) %>%
        unnest_wider(.data$parameters) %>%
        select(-c(.data$associatedPollutants)) %>%
        mutate(sources = purrr::map(.data$sources,
                                    ~{
                                      q_unnest_l = purrr::possibly(.f = unnest_longer,
                                                                   otherwise = NULL)
                                      q_unnest_w = purrr::possibly(.f = unnest_wider,
                                                                   otherwise = NULL)
                                      tibble::enframe(.x) %>%
                                        select(-c(.data$name)) %>%
                                        unnest_wider(.data$value)
                                    })) %>%
        unnest_wider(.data$TMDLReportDetails) %>%
        clean_names()-> content_actions

      return(list(documents = content_docs,
                  actions = content_actions))

    }
  }

}
