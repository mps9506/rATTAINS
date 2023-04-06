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
#' @param .unnest (logical) \code{TRUE} (default) the function attempts to unnest
#'   data to longest format possible. This defaults to \code{TRUE} for backwards
#'   compatibility but it is suggested to use \code{FALSE}.
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
#' @importFrom lifecycle deprecate_warn
#' @importFrom rlist list.filter
#' @importFrom rlang .data is_empty
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
                    .unnest = TRUE,
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
         x = list(summarize, tidy, .unnest),
         .var.name = c("summarize", "tidy", ".unnest"),
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
                                 summarize = summarize,
                                 .unnest = .unnest)

    return(content)
  }
}


#' Convert Action JSON to Tibble
#'
#' @param content json
#' @param count logical
#' @param summarize character
#' @param .unnest logical
#' @keywords internal
#' @noRd
#' @import tibblify
#' @importFrom dplyr select
#' @importFrom jsonlite fromJSON
#' @importFrom tidyr unpack unnest unnest_longer
#' @importFrom tidyselect everything
actions_to_tibble <- function(content,
                  count = FALSE,
                  summarize = "N",
                  .unnest) {

  ## parse JSON
  json_list <- jsonlite::fromJSON(content,
                                  simplifyVector = FALSE,
                                  simplifyDataFrame = FALSE,
                                  flatten = FALSE)

  ## Create tibblify specification
  spec <- spec_actions(summarize = summarize)

  ## Create nested lists according to spec
  content <- tibblify(json_list,
                      spec = spec,
                      unspecified = "drop")

  ## lists -> rectangle
  content <- unnest(content$items, cols = everything(), keep_empty = TRUE)
  content <- unpack(content, cols = everything())

  ## if unnest == FALSE do not unnest data
  if(!isTRUE(.unnest)) {
    return(content)
  }

  ## data structure if request was made with summarize = TRUE
  if(summarize == "Y") {
    content <- unnest_longer(content, col = "documents")
    content <- unpack(content, cols = everything(), names_repair = "universal")
    content <- unnest_longer(content, col = "associated_pollutants")
    content <- unnest(content, cols = "document_types", keep_empty = TRUE)
    content <- select(content, -c("parameters"))

    return(content)
  }
  ## data structure if request was made with summarize = FALSE
  if(summarize == "N") {
    ## returns a list of two tibbles: documents and actions
    documents <- select(content, -c("specific_waters"))
    documents <- unnest(documents, cols = everything(), names_repair = "universal", keep_empty = TRUE)
    documents <- unnest(documents, cols = everything(), names_repair = "universal", keep_empty = TRUE)

    actions <- select(content, -c("documents"))
    actions <- unnest_longer(actions, col = "specific_waters")
    actions <- unpack(actions, cols = everything())
    actions <- unnest(actions, cols = "associated_pollutants", keep_empty = TRUE)
    actions <- unnest(actions, cols = -c("permits", "parameters"), keep_empty = TRUE)

    return(list(documents = documents,
                actions = actions))
  }
}

#' Create tibblify specification for actions
#' @param summarize character, one of 'Y' or 'N'.
#' @return tibblify specification
#' @keywords internal
#' @noRd
#' @import tibblify
spec_actions <- function(summarize) {

  if(summarize == "N") {

    spec <- tspec_object(
      "items" = tib_df(
        "items",
        "organization_identifier" = tib_chr("organizationIdentifier", required = FALSE),
        "organization_name" = tib_chr("organizationName", required = FALSE),
        "organization_type_text" = tib_chr("organizationTypeText", required = FALSE),
        "actions" = tib_df(
          "actions",
          "action_identifier" = tib_chr("actionIdentifier", required = FALSE),
          "action_name" = tib_chr("actionName", required = FALSE),
          "actionAgencyCode" =  tib_chr("agencyCode", required = FALSE),
          "action_type_code" = tib_chr("actionTypeCode", required = FALSE),
          "action_status_code" = tib_chr("actionStatusCode", required = FALSE),
          "completion_date" = tib_chr("completionDate", required = FALSE),
          "organization_id" = tib_chr("organizationId", required = FALSE),
          "documents" = tib_df(
            "documents",
            "documentAgencyCode" = tib_chr("agencyCode", required = FALSE),
            "document_types" = tib_df(
              "documentTypes",
              "document_type_code" = tib_chr("documentTypeCode", required = FALSE),
            ),
            "document_file_type" = tib_chr("documentFileType", required = FALSE),
            "document_file_name" = tib_chr("documentFileName", required = FALSE),
            "document_name" = tib_chr("documentName", required = FALSE),
            "document_description" = tib_unspecified("documentDescription", required = FALSE),
            "document_comments" = tib_chr("documentComments", required = FALSE),
            "document_url" = tib_chr("documentURL", required = FALSE),
          ),
          "associated_waters" = tib_row(
            "associatedWaters",
            "specific_waters" = tib_df(
              "specificWaters",
              "asessment_unit_identifier" = tib_chr("assessmentUnitIdentifier", required = FALSE),
              "associated_pollutants" = tib_df(
                "associatedPollutants",
                "pollutant_name" = tib_chr("pollutantName", required = FALSE),
                "pollutant_source_type_code" = tib_chr("pollutantSourceTypeCode", required = FALSE),
                "explicit_margin_of_safety_text" = tib_chr("explicitMarginofSafetyText", required = FALSE),
                "implicit_margin_of_safety_text" = tib_chr("implicitMarginofSafetyText", required = FALSE),
                "load_allocation_details" = tib_df(
                  "loadAllocationDetails",
                  "load_allocation_numeric" = tib_dbl("loadAllocationNumeric", required = FALSE),
                  "load_allocation_units_text" = tib_chr("loadAllocationUnitsText", required = FALSE),
                  "season_start_text" = tib_unspecified("seasonStartText", required = FALSE),
                  "seasons_end_text" = tib_unspecified("seasonEndText", required = FALSE),
                ),
                "permits" = tib_df(
                  "permits",
                  "NPDES_identifier" = tib_chr("NPDESIdentifier", required = FALSE),
                  "other_identifier" = tib_chr("otherIdentifier", required = FALSE),
                  "details" = tib_df(
                    "details",
                    "waste_load_allocation_numeric" = tib_dbl("wasteLoadAllocationNumeric", required = FALSE),
                    "waste_load_allocation_units_text" = tib_chr("wasteLoadAllocationUnitsText", required = FALSE),
                    "season_start_text" = tib_unspecified("seasonStartText", required = FALSE),
                    "season_end_text" = tib_unspecified("seasonEndText", required = FALSE),
                  ),
                ),
                "TMDL_end_point_text" = tib_chr("TMDLEndPointText", required = FALSE),
              ),
              "parameters" = tib_df(
                "parameters",
                "parameters_name" = tib_chr("parameterName", required = FALSE),
                "associated_pollutants" = tib_df(
                  "associatedPollutants",
                  "pollutant_name" = tib_chr("pollutantName", required = FALSE),
                ),
              ),
              "sources" = tib_unspecified("sources", required = FALSE),
            ),
          ),
          "TMDL_report_details" = tib_row(
            "TMDLReportDetails",
            "TMDL_other_identifier" = tib_unspecified("TMDLOtherIdentifier", required = FALSE),
            "TMDL_date" = tib_chr("TMDLDate", required = FALSE),
            "indian_country_indicator" = tib_chr("indianCountryIndicator", required = FALSE),
          ),
          "pollutants" = tib_unspecified("pollutants", required = FALSE),
          "associated_actions" = tib_unspecified("associatedActions", required = FALSE),
          "histories" = tib_unspecified("histories", required = FALSE),
        ),
      ),
      "count" = tib_int("count", required = FALSE),
    )
  }
  if(summarize == "Y") {

    spec <- tspec_object(
      "items" = tib_df(
        "items",
        "organization_identifier" = tib_chr("organizationIdentifier", required = FALSE),
        "organization_name" = tib_chr("organizationName", required = FALSE),
        "organization_type_text" = tib_chr("organizationTypeText", required = FALSE),
        "actions" = tib_df(
          "actions",
          "action_identifier" = tib_chr("actionIdentifier", required = FALSE),
          "action_name" = tib_chr("actionName", required = FALSE),
          "agency_code" = tib_chr("agencyCode", required = FALSE),
          "action_type_code" = tib_chr("actionTypeCode", required = FALSE),
          "action_status_code" = tib_chr("actionStatusCode", required = FALSE),
          "completion_date" = tib_chr("completionDate", required = FALSE),
          "organization_id" = tib_chr("organizationId", required = FALSE),
          "documents" = tib_df(
            "documents",
            "agency_code" = tib_chr("agencyCode", required = FALSE),
            "document_types" = tib_df(
              "documentTypes",
              "document_type_code" = tib_chr("documentTypeCode", required = FALSE),
            ),
            "document_file_type" = tib_chr("documentFileType", required = FALSE),
            "document_file_name" = tib_chr("documentFileName", required = FALSE),
            "document_name" = tib_chr("documentName", required = FALSE),
            "document_description" = tib_unspecified("documentDescription", required = FALSE),
            "document_comments" = tib_chr("documentComments", required = FALSE),
            "document_url" = tib_chr("documentURL", required = FALSE),
          ),
          "TMDL_report_details" = tib_row(
            "TMDLReportDetails",
            "TMDL_other_identifier" = tib_unspecified("TMDLOtherIdentifier", required = FALSE),
            "TMDL_date" = tib_chr("TMDLDate", required = FALSE),
            "indian_country_indicator" = tib_chr("indianCountryIndicator", required = FALSE),
          ),
          "associated_pollutants" = tib_df(
            "associatedPollutants",
            "pollutant_name" = tib_chr("pollutantName", required = FALSE),
            "au_count" = tib_chr("auCount", required = FALSE),
          ),
          "parameters" = tib_df(
            "parameters",
            "parameter_name" = tib_chr("parameterName", required = FALSE),
            "au_count" = tib_chr("auCount", required = FALSE),
          ),
          "associated_actions" = tib_unspecified("associatedActions", required = FALSE),
        ),
      ),
      "count" = tib_int("count", required = FALSE),
    )
  }

  return(spec)
}
