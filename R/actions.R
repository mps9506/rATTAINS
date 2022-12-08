#' Download Actions Data
#'
#' @description Provides data about actions (TMDLs, 4B Actions, Alternative Actions,
#' Protection Approach Actions) that have been finalized.
#'
#' @param action_id (character) Specifies what action to retrieve. multiple
#'   values allowed. optional
#' @param assessment_unit_id (character) Filters returned actions to those
#'   associated with the specified assessment unit identifier, plus any
#'   statewide actions. multiple values allowed. optional
#' @param state_code (character) Filters returned actions to those "belonging"
#'   to the specified state. optional
#' @param organization_id (character) Filter returned actions to those
#'   "belonging" to specified organizations. multiple values allowed. optional
#' @param summarize (logical) If \code{TRUE} provides only a count of the
#'   assessment units for the action and summary of the pollutants and
#'   parameters covered by the action.
#' @param parameter_name (character) Filters returned actions to those
#'   associated with the specified parameter. multiple values allowed. optional
#' @param pollutant_name (character) Filters returned actions to those
#'   associated with the specified pollutant. multiple values allowed. optional
#' @param action_type_code (character) Filters returned actions to those
#'   associated with the specified action type code. multiple values allowed.
#'   optional
#' @param agency_code (character) Filters returned actions to those with the
#'   specified agency code. multiple values allowed. optional
#' @param pollutant_source_code (character) Filters returned actions to those
#'   matching the specified pollutant source code. multiple values allowed.
#'   optional
#' @param action_status_code (character) Filters returned actions to those
#'   matching the specified action status code. multiple values allowed.
#'   optional
#' @param completion_date_later_than (character) Filters returned actions to
#'   those with a completion date later than the value specified. Must be a
#'   character formatted as \code{"YYYY-MM-DD"}. optional
#' @param completion_date_earlier_than (character) Filters returned actions to
#'   those with a completion date earlier than the value specified. Must be a
#'   character formatted as \code{"YYYY-MM-DD"}. optional
#' @param tmdl_date_later_than (character) Filters returned actions to those
#'   with a TMDL date later than the value specified. Must be a character
#'   formatted as \code{"YYYY-MM-DD"}. optional
#' @param tmdl_date_earlier_then (character) Filters returned actions to those
#'   with a TMDL date earlier than the value specified. Must be a character
#'   formatted as \code{"YYYY-MM-DD"}. optional
#' @param last_change_later_than_date (character) Filters returned actions to
#'   those with a last change date later than the value specified. Can be used
#'   with \code{last_change_earlier_than_date} to return actions changed within
#'   a date range. Must be a character formatted as \code{"YYYY-MM-DD"}.
#'   optional
#' @param last_change_earlier_than_date (character) Filters returned actions to
#'   those with a last change date earlier than the value specified. Can be used
#'   with \code{last_change_later_than_date} to return actions changed within a
#'   date range. Must be a character formatted as \code{"YYYY-MM-DD"}. optional
#' @param return_count_only (logical) If \code{TRUE} returns only the count of
#'   actions the match the query.
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied
#'   tibble. \code{FALSE} the function returns the raw JSON string.
#' @param ... list of curl options passed to [crul::HttpClient()]
#' @details One or more of the following arguments must be included:
#'   \code{action_id}, \code{assessment_unit_id}, \code{state_code} or
#'   \code{organization_id}. Multiple values are allowed for indicated arguments
#'   and should be included as a comma separated values in the string (eg.
#'   \code{organization_id="TCEQMAIN,DCOEE"}).
#' @return If \code{count = TRUE} returns a tibble that summarizes the count of
#'   actions returned by the query. If \code{count = FALSE} returns a list of
#'   tibbles including documents and actions identified by the query. If
#'   \code{tidy = FALSE} the raw JSON string is returned, else the JSON data is
#'   parsed and returned as tibbles.
#' @note See [domain_values] to search values that can be queried.
#' @export
#' @importFrom checkmate assert_character assert_logical makeAssertCollection
#'   reportAssertions
#' @importFrom fs path
#' @importFrom rlist list.filter
#' @importFrom rlang is_empty
#' @examples
#' \dontrun{
#'
#' ## Look up an individual action
#' actions(action_id = "R8-ND-2018-03")

#' ## Get the JSON instead
#' actions(action_id = "R8-ND-2018-03", tidy = FALSE)
#' }
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
                    tidy = TRUE,
                    ...) {

  ## check connectivity
  #check_connectivity()

  ## check that arguments are character
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_character,
         x = list(action_id, assessment_unit_id, state_code,
                  organization_id, parameter_name, pollutant_name,
                  action_type_code, agency_code, pollutant_source_code,
                  action_status_code, completion_date_later_than,
                  completion_date_earlier_than, tmdl_date_later_than,
                  tmdl_date_earlier_then, last_change_earlier_than_date,
                  last_change_later_than_date),
         .var.name = c("action_id","assessment_unit_id", "state_code",
                       "organization_id", "parameter_name", "pollutant_name",
                       "action_type_code", "agency_code", "pollutant_source_code",
                       "action_status_code", "completion_date_later_than",
                       "completion_date_earlier_than", "tmdl_date_later_than",
                       "tmdl_date_earlier_then", "last_change_earlier_than_date",
                       "last_change_later_than_date"),
         MoreArgs = list(null.ok = TRUE,
                         add = coll))
  checkmate::reportAssertions(coll)

  ## check logical
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_logical,
         x = list(summarize, tidy),
         .var.name = c("summarize", "tidy"),
         MoreArgs = list(null.ok = TRUE,
                         add = coll))
  checkmate::reportAssertions(coll)

  ## change logical aguments to "Y" or "N" for webservice
  returnCountOnly <- if(isTRUE(return_count_only)) {
    "Y"
  } else {"N"}
  summarize <- if(isTRUE(summarize)) {
    "Y"
  } else {"N"}

  ## check required args are present
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
  path <- "attains-public/api/actions"

  ## download data without caching
  content <- xGET(path,
                  args,
                  file = NULL,
                  ...)


  if(is.null(content)) return(content)
  ## return raw JSON
  if(!isTRUE(tidy)) return(content)

  ## parse and tidy JSON
  else {
    content <- actions_to_tibble(content,
                                 count = returnCountOnly,
                                 summarize = summarize)

    return(content)
  }
}


#' Convert Action JSON to Tibble
#'
#' @param content json
#' @param count logical
#' @param summarize character
#' @keywords internal
#' @noRd
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
