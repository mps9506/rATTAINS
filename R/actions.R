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
#' @param return_count_only `r lifecycle::badge("deprecated")`
#'   `return_count_only = TRUE` is no longer supported.
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied
#'   tibble. \code{FALSE} the function returns the raw JSON string.
#' @param ... list of curl options passed to [crul::HttpClient()]
#' @details One or more of the following arguments must be included:
#'   \code{action_id}, \code{assessment_unit_id}, \code{state_code} or
#'   \code{organization_id}. Multiple values are allowed for indicated arguments
#'   and should be included as a comma separated values in the string (eg.
#'   \code{organization_id="TCEQMAIN,DCOEE"}).
#' @return If \code{tidy = FALSE} the raw JSON string is returned, else the
#'   JSON data is parsed and returned as tibbles.
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

  ## depreciate return_count_only
  if (isTRUE(return_count_only)) {
    lifecycle::deprecate_warn(
      when = "1.0.0",
      what = "actions(return_count_only)",
      details = "Ability to retun counts only is depreciated and defaults to
      FALSE. The `return_count_only` argument will be removed in future
      releases."
    )
  }
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
  #### DEPRECIATED ####
  # returnCountOnly <- if(isTRUE(return_count_only)) {
  #   "Y"
  # } else {"N"}
  #####################
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
               ### DEPRECIATED ###
               #returnCountOnly = returnCountOnly)#
               ###################
               returnCountOnly = "N"
  )
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
                                 count = FALSE, ## depreciated to FALSE
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
#' @import tibblify
#' @importFrom dplyr select
#' @importFrom janitor clean_names
#' @importFrom tidyr unpack unnest
#' @importFrom tidyselect everything
actions_to_tibble <- function(content,
                  count = FALSE,
                  summarize = "N") {

  json_list <- jsonlite::fromJSON(content,
                                  simplifyVector = FALSE,
                                  simplifyDataFrame = FALSE,
                                  flatten = FALSE)


  spec <- spec_actions(summarize = summarize)
  content <- tibblify(json_list,
                      spec = spec,
                      unspecified = "drop")
  content <- unnest(content$items, cols = everything(), keep_empty = TRUE)
  content <- unpack(content, cols = everything())


  if(summarize == "Y") {
    content <- unnest_longer(content, col = "documents")
    content <- unpack(content, cols = everything(), names_repair = "universal")
    content <- unnest_longer(content, col = "associatedPollutants")
    content <- unnest(content, cols = "documentTypes", keep_empty = TRUE)
    content <- select(content, -c("parameters"))

    content <- clean_names(content)

    return(content)
  }
  if(summarize == "N") {
    documents <- select(content, -c("specificWaters"))
    documents <- unnest(documents, cols = everything(), names_repair = "universal", keep_empty = TRUE)
    documents <- unnest(documents, cols = everything(), names_repair = "universal", keep_empty = TRUE)
    documents <- clean_names(documents)

    actions <- select(content, -c("documents"))
    actions <- unnest_longer(actions, col = "specificWaters")
    actions <- unpack(actions, cols = everything())
    actions <- unnest(actions, cols = "associatedPollutants", keep_empty = TRUE)
    actions <- unnest(actions, cols = -c("permits", "parameters"), keep_empty = TRUE)
    actions <- clean_names(actions)

    return(list(documents = documents,
                actions = actions))
  }
}


## creates default tibblify specs for actions
spec_actions <- function(summarize = "N") {

  if(summarize == "N") {

    spec <- tspec_object(
      tib_df(
        "items",
        tib_chr("organizationIdentifier"),
        tib_chr("organizationName"),
        tib_chr("organizationTypeText"),
        tib_df(
          "actions",
          tib_chr("actionIdentifier"),
          tib_chr("actionName"),
          tib_chr("agencyCode"),
          tib_chr("actionTypeCode"),
          tib_chr("actionStatusCode"),
          tib_chr("completionDate"),
          tib_chr("organizationId"),
          tib_df(
            "documents",
            tib_chr("agencyCode"),
            tib_df(
              "documentTypes",
              tib_chr("documentTypeCode"),
            ),
            tib_chr("documentFileType"),
            tib_chr("documentFileName"),
            tib_chr("documentName"),
            tib_unspecified("documentDescription"),
            tib_chr("documentComments"),
            tib_chr("documentURL"),
          ),
          tib_row(
            "associatedWaters",
            tib_df(
              "specificWaters",
              tib_chr("assessmentUnitIdentifier"),
              tib_df(
                "associatedPollutants",
                tib_chr("pollutantName"),
                tib_chr("pollutantSourceTypeCode"),
                tib_chr("explicitMarginofSafetyText"),
                tib_chr("implicitMarginofSafetyText"),
                tib_df(
                  "loadAllocationDetails",
                  tib_dbl("loadAllocationNumeric"),
                  tib_chr("loadAllocationUnitsText"),
                  tib_unspecified("seasonStartText"),
                  tib_unspecified("seasonEndText"),
                ),
                tib_df(
                  "permits",
                  tib_chr("NPDESIdentifier"),
                  tib_chr("otherIdentifier"),
                  tib_df(
                    "details",
                    tib_dbl("wasteLoadAllocationNumeric"),
                    tib_chr("wasteLoadAllocationUnitsText"),
                    tib_unspecified("seasonStartText"),
                    tib_unspecified("seasonEndText"),
                  ),
                ),
                tib_chr("TMDLEndPointText"),
              ),
              tib_df(
                "parameters",
                tib_chr("parameterName"),
                tib_df(
                  "associatedPollutants",
                  tib_chr("pollutantName"),
                ),
              ),
              tib_unspecified("sources"),
            ),
          ),
          tib_row(
            "TMDLReportDetails",
            tib_unspecified("TMDLOtherIdentifier", required = FALSE),
            tib_chr("TMDLDate", required = FALSE),
            tib_chr("indianCountryIndicator", required = FALSE),
          ),
          tib_unspecified("pollutants"),
          tib_unspecified("associatedActions"),
          tib_unspecified("histories"),
        ),
      ),
      tib_int("count"),
    )
  }
  if(summarize == "Y") {

    spec <- tspec_object(
      tib_df(
        "items",
        tib_chr("organizationIdentifier"),
        tib_chr("organizationName"),
        tib_chr("organizationTypeText"),
        tib_df(
          "actions",
          tib_chr("actionIdentifier"),
          tib_chr("actionName"),
          tib_chr("agencyCode"),
          tib_chr("actionTypeCode"),
          tib_chr("actionStatusCode"),
          tib_chr("completionDate"),
          tib_chr("organizationId"),
          tib_df(
            "documents",
            tib_chr("agencyCode"),
            tib_df(
              "documentTypes",
              tib_chr("documentTypeCode"),
            ),
            tib_chr("documentFileType"),
            tib_chr("documentFileName"),
            tib_chr("documentName"),
            tib_unspecified("documentDescription"),
            tib_chr("documentComments"),
            tib_chr("documentURL"),
          ),
          tib_row(
            "TMDLReportDetails",
            tib_unspecified("TMDLOtherIdentifier"),
            tib_chr("TMDLDate"),
            tib_chr("indianCountryIndicator"),
          ),
          tib_df(
            "associatedPollutants",
            tib_chr("pollutantName"),
            tib_chr("auCount"),
          ),
          tib_df(
            "parameters",
            tib_chr("parameterName"),
            tib_chr("auCount"),
          ),
          tib_unspecified("associatedActions"),
        ),
      ),
      tib_int("count"),
    )
  }

  return(spec)
}
