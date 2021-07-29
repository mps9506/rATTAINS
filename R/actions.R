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
#' @importFrom rlist list.filter
#' @importFrom rlang is_empty
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

  ## setup file cache
  actions_cache <- hoardr::hoard()
  path <- "attains-public/api/actions"
  file <- actions_key(path = path, arg_list = args)
  actions_cache$cache_path_set(path = file)
  actions_cache$mkdir()

  ## need to setup logic to check if file exists, skip if it does and read file.

  content <- xGET(path,
                  args,
                  file = file.path(actions_cache$cache_path_get(),
                                               "actions.json"),
                  ...)
  content <- actions_to_tibble(content,
                               count = returnCountOnly,
                               summarize = summarize)

  return(content)
}


#' Convert Action JSON to Tibble
#'
#' @param content json
#' @param count logical
#' @param summarize character
#' @keywords internal
#' @export
#' @import tidyjson
#' @importFrom dplyr select rename
#' @importFrom janitor clean_names
#' @importFrom tibble as_tibble
#' @importFrom rlang .data
actions_to_tibble <- function(content,
                  count = FALSE,
                  summarize = FALSE) {

  if(isTRUE(count)) {
    return(content %>%
             spread_all() %>%
             select(.data$count) %>%
             as_tibble() %>%
             clean_names())
  } else {
    if(summarize == "Y") {
      content %>%
        enter_object("items") %>%
        gather_array() %>%
        spread_all() %>%
        select(-c(.data$array.index, .data$document.id)) %>%
        enter_object("actions") %>%
        gather_array() %>%
        spread_all(recursive = TRUE) %>%
        select(-c(.data$array.index)) %>%
        as_tibble() %>%
        clean_names() -> content
      return(content)
      } else{
      content %>%
        enter_object("items") %>%
        gather_array() %>%
        spread_all() %>%
        select(-c(.data$array.index)) %>%
        enter_object("actions") %>%
        gather_array() %>%
        spread_all() %>%
        select(-c(.data$array.index)) %>%
        enter_object("associatedWaters") %>%
        enter_object("specificWaters") %>%
        gather_array() %>%
        spread_all() %>%
        select(-c(.data$array.index)) %>%
        enter_object("associatedPollutants") %>%
        gather_array() %>%
        spread_all(recursive = TRUE) %>%
        select(-c(.data$document.id, .data$array.index)) %>%
        as_tibble() %>%
        clean_names() -> content_actions

      content %>%
        enter_object("items") %>%
        gather_array() %>%
        spread_all() %>%
        select(-c(.data$array.index, .data$document.id)) %>%
        enter_object("actions") %>%
        gather_array() %>%
        spread_all() %>%
        select(-c(.data$array.index)) %>%
        dplyr::rename(agencyCode_1 = .data$agencyCode) %>%
        enter_object("documents") %>%
        gather_array() %>%
        spread_all() %>%
        select(-c(.data$array.index)) %>%
        enter_object("documentTypes") %>%
        gather_array() %>%
        spread_all(recursive = TRUE) %>%
        select(-c(.data$array.index)) %>%
        as_tibble() %>%
        clean_names()-> content_docs

      return(list(documents = content_docs,
                  actions = content_actions))

    }
  }

}

# returns the unique file path for the cached file
actions_key <- function(path, arg_list) {
  x <- paste0(arg_list, collapse = "_")
  x <- file.path(path, x)
  #x <- paste0(path, "/", x,"/actions.json")
  return(x)
}
