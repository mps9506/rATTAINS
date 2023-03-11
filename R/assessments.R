#' Download Assessment Decisions
#'
#' @param assessment_unit_id (character) Specify the specific assessment unit assessment data to return. Multiple values can be provided. optional
#' @param state_code (character) Filters returned assessments to those from the specified state. optional
#' @param organization_id (character) Filters the returned assessments to those belonging to the specified organization. optional
#' @param reporting_cycle (character) Filters the returned assessments to those for the specified reporting cycle. The reporting cycle refers to the four-digit year that the reporting cycle ended. Defaults to the current cycle. optional
#' @param use (character) Filters the returned assessments to those with the specified uses. Multiple values can be provided. optional
#' @param use_support (character) Filters returned assessments to those fully supporting the specified uses or that are threatened. Multiple values can be provided. Allowable values include \code{"X"}= Not Assessed, \code{"I"}= Insufficient Information, \code{"F"}= Fully Supporting, \code{"N"}= Not Supporting, and \code{"T"}= Threatened. optional
#' @param parameter (character) Filters the returned assessments to those with one or more of the specified parameters. Multiple values can be provided. optional
#' @param parameter_status_name (character) Filters the returned assessments to those with one or more associated parameters meeting the provided value. Valid values are \code{"Meeting Criteria"}, \code{"Cause"}, \code{"Observed Effect"}. Multiple valuse can be provided. optional
#' @param probable_source (character) Filters the returned assessments to those having the specified probable source. Multiple values can be provided. optional
#' @param agency_code (character) Filters the returned assessments to those by the type of agency responsible for the assessment. Allowed values are \code{"E"}=EPA, \code{"S"}=State, \code{"T"}=Tribal. optional
#' @param ir_category (character) Filters the returned assessments to those having the specified IR category. Multiple values can be provided. optional
#' @param state_ir_category_code (character) Filters the returned assessments to include those having the provided codes.
#' @param multicategory_search (character) Specifies whether to search at multiple levels.  If this parameter is set to “Y” then the query applies the EPA IR Category at the Assessment, UseAttainment, and Parameter levels; if the parameter is set to “N” it looks only at the Assessment level.
#' @param last_change_later_than_date (character) Filters the returned assessments to only those last changed after the provided date. Must be a character
#'   with format: \code{"yyyy-mm-dd"}. optional
#' @param last_change_earlier_than_date (character) Filters the returned assessments to only those last changed before the provided date. Must be a character
#'   with format: \code{"yyyy-mm-dd"}. optional
#' @param return_count_only `r lifecycle::badge("deprecated")`
#'   `return_count_only = TRUE` is no longer supported.
#' @param exclude_assessments (logical) If \code{TRUE} returns only the documents associated with the Assessment cycle instead of the assessment data. Defaults is \code{FALSE}.
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied tibble. \code{FALSE} the function returns the raw JSON string.
#' @param ... list of curl options passed to [crul::HttpClient()]
#' @details One or more of the following arguments must be included:
#'   \code{action_id}, \code{assessment_unit_id}, \code{state_code} or
#'   \code{organization_id}. Multiple values are allowed for indicated arguments
#'   and should be included as a comma separated values in the string (eg.
#'   \code{organization_id="TCEQMAIN,DCOEE"}).
#' @return If \code{tidy = FALSE} the raw JSON string is
#'   returned, else the JSON data is parsed and returned as tibbles.
#' @note See [domain_values] to search values that can be queried. In v1.0.0 rATTAINS returns a list of tibbles (`documents`, `use_assessment`, `delisted_waters`). Prior versions returned `documents`, `use_assessment`, and `parameter_assessment`.
#' @export
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
#' @importFrom fs path
#' @importFrom rlist list.filter
#' @importFrom rlang is_empty .data
#' @examples
#'
#' \dontrun{
#'
#' ## Return all assessment decisions with specified parameters
#' assessments(organization_id = "SDDENR",
#' probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES")
#'
#' ## Returns the raw JSONs instead:
#' assessments(organization_id = "SDDENR",
#' probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES", tidy = FALSE)
#' }
assessments <- function(assessment_unit_id = NULL,
                        state_code = NULL,
                        organization_id = NULL,
                        reporting_cycle = NULL,
                        use = NULL,
                        use_support = NULL,
                        parameter = NULL,
                        parameter_status_name = NULL,
                        probable_source = NULL,
                        agency_code = NULL,
                        ir_category = NULL,
                        state_ir_category_code = NULL,
                        multicategory_search = NULL,
                        last_change_later_than_date = NULL,
                        last_change_earlier_than_date = NULL,
                        return_count_only = FALSE,
                        exclude_assessments = FALSE,
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
  check_connectivity()

  ## check that arguments are character
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_character,
         x = list(assessment_unit_id, state_code, organization_id,
                  reporting_cycle, use, use_support, parameter,
                  parameter_status_name, probable_source, agency_code,
                  ir_category, state_ir_category_code, multicategory_search,
                  last_change_later_than_date, last_change_earlier_than_date),
         .var.name = c("assessment_unit_id", "state_code", "organization_id",
                       "reporting_cycle", "use", "use_support", "parameter",
                       "parameter_status_name", "probable_source", "agency_code",
                       "ir_category", "state_ir_category_code", "multicategory_search",
                       "last_change_later_than_date", "last_change_earlier_than_date"),
         MoreArgs = list(null.ok = TRUE,
                         add = coll))
  checkmate::reportAssertions(coll)

  ## check logical
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_logical,
         x = list(return_count_only, exclude_assessments, tidy),
         .var.name = c("return_count_only", "exclude_assessments", "tidy"),
         MoreArgs = list(null.ok = TRUE,
                         add = coll))
  checkmate::reportAssertions(coll)

  #### DEPRECIATED ####
  # returnCountOnly <- if(isTRUE(return_count_only)) {
  #   "Y"
  # } else {"N"}
  #####################
  exclude_assessments <- if(isTRUE(exclude_assessments)) {
    "Y"
  } else {"N"}

  args <- list(assessmentUnitIdentifier = assessment_unit_id,
               state = state_code,
               organizationId = organization_id,
               reportingCycle = reporting_cycle,
               use = use,
               useSupport = use_support,
               parameter = parameter,
               parameterStatusName = parameter_status_name,
               probableSource = probable_source,
               agencyCode = agency_code,
               irCategory = ir_category,
               stateIRCategoryCode = state_ir_category_code,
               multicategorySearch = multicategory_search,
               lastChangeLaterThanDate = last_change_later_than_date,
               lastChangeEarlierThanDate = last_change_earlier_than_date,
               ### DEPRECIATED ###
               #returnCountOnly = returnCountOnly)#
               ###################
               returnCountOnly = "N",
               excludeAssessments = exclude_assessments)

  args <- list.filter(args, !is.null(.data))
  required_args <- c("assessmentUnitIdentifier",
                     "state",
                     "organizationId")
  args_present <- intersect(names(args), required_args)
  if(is_empty(args_present)) {
    stop("One of the following arguments must be provided: assessment_unit_identifer, state_code, or organization_id")
  }

  path = "attains-public/api/assessments"

  ## download without caching
  content <- xGET(path,
                  args,
                  file = NULL,
                  ...)

  if(is.null(content)) return(content)

  if (!isTRUE(tidy)) {
    return(content)
  } else{
    ## parse the returned json
    content <- assessments_to_tibble(content,
                                     count = return_count_only,
                                     exclude_assessments = exclude_assessments)

    return(content)
  }
}


#'
#' @param content raw JSON
#' @param count logical
#' @param exclude_assessments "Y" or "N"
#'
#' @noRd
#' @import tibblify
#' @importFrom dplyr select
#' @importFrom janitor clean_names
#' @importFrom jsonlite fromJSON
#' @importFrom tidyr unnest
#' @importFrom tidyselect everything
assessments_to_tibble <- function(content,
                                  count = FALSE,
                                  exclude_assessments) {
  # parse JSON
  json_list <- jsonlite::fromJSON(content,
                                  simplifyVector = FALSE,
                                  simplifyDataFrame = FALSE,
                                  flatten = FALSE)

  ## Create tibblify specification
  spec <- spec_assessments(exclude_assessments = exclude_assessments)

  ## Create nested lists according to spec
  content <- tibblify(json_list,
                      spec = spec,
                      unspecified = "drop")

  if(exclude_assessments == "N") {

    content_documents <- select(content$items, -c("assessments", "delistedWaters"))
    content_documents <- unnest(content_documents, cols = everything(), keep_empty = TRUE)
    content_documents <- unnest(content_documents, cols = everything(), keep_empty = TRUE)


    content_assessments <- select(content$items, -c("documents", "delistedWaters"))
    content_assessments <- unnest(content_assessments, cols = everything(), keep_empty = TRUE)


    content_delisted_waters <- select(content$items, -c("documents", "assessments"))
    content_delisted_waters <- unnest(content_delisted_waters, cols = everything(), keep_empty = TRUE)
    content_delisted_waters <- unnest(content_delisted_waters, cols = everything(), keep_empty = TRUE)

    return(list(documents = content_documents,
                use_assessment = content_assessments,
                delisted_waters = content_delisted_waters))
  }
  if(exclude_assessments == "Y") {

    content <- unnest(content$items, cols = everything(), keep_empty = TRUE)
    content <- unnest(content, cols = everything(), keep_empty = TRUE)
    return(content)
  }
}

#' Create tibblify specification for assessment_units
#'
#' @param exclude_assessments "Y" or "N"
#' @return tibblify specification
#' @keywords internal
#' @noRd
#' @import tibblify
spec_assessments <- function(exclude_assessments) {

  if(exclude_assessments == "N") {
    spec <- tspec_object(
      tib_df(
        "items",
        tib_chr("organizationIdentifier"),
        tib_chr("organizationName"),
        tib_chr("organizationTypeText"),
        tib_chr("reportingCycleText"),
        tib_unspecified("combinedCycles"),
        tib_chr("reportStatusCode"),
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
          tib_chr("documentDescription"),
          tib_chr("documentComments"),
          tib_chr("documentURL"),
        ),
        tib_df(
          "assessments",
          tib_chr("assessmentUnitIdentifier"),
          tib_chr("agencyCode"),
          tib_chr("trophicStatusCode"),
          tib_df(
            "useAttainments",
            tib_chr("useName"),
            tib_chr("useAttainmentCode"),
            tib_chr("threatenedIndicator"),
            tib_chr("trendCode"),
            tib_chr("agencyCode"),
            tib_row(
              "assessmentMetadata",
              tib_chr("assessmentBasisCode", required = FALSE),
              tib_df(
                "assessmentTypes",
                .required = FALSE,
                tib_chr("assessmentTypeCode"),
                tib_chr("assessmentConfidenceCode"),
              ),
              tib_df(
                "assessmentMethodTypes",
                .required = FALSE,
                tib_chr("methodTypeContext"),
                tib_chr("methodTypeCode"),
                tib_chr("methodTypeName"),
              ),
              tib_row(
                "monitoringActivity",
                .required = FALSE,
                tib_chr("monitoringStartDate", required = FALSE),
                tib_chr("monitoringEndDate", required = FALSE),
              ),
              tib_row(
                "assessmentActivity",
                .required = FALSE,
                tib_chr("assessmentDate", required = FALSE),
                tib_chr("assessorName", required = FALSE),
              ),
            ),
            tib_chr("useAttainmentCodeName"),
          ),
          tib_df(
            "parameters",
            tib_chr("parameterStatusName"),
            tib_chr("parameterName"),
            tib_df(
              "associatedUses",
              tib_chr("associatedUseName"),
              tib_chr("parameterAttainmentCode"),
              tib_chr("trendCode"),
              tib_df("seasons"),
            ),
            tib_df(
              "impairedWatersInformation",
              .names_to = ".names",
              tib_chr("agencyCode", required = FALSE),
              tib_chr("cycleFirstListedText", required = FALSE),
              tib_chr("cycleScheduledForTMDLText", required = FALSE),
              tib_chr("CWA303dPriorityRankingText", required = FALSE),
              tib_chr("consentDecreeCycleText", required = FALSE),
              tib_unspecified("alternateListingIdentifier", required = FALSE),
              tib_chr("cycleExpectedToAttain", required = FALSE),
            ),
            tib_df(
              "associatedActions",
              tib_chr("associatedActionIdentifier"),
            ),
            tib_chr("pollutantIndicator"),
          ),
          tib_df(
            "probableSources",
            tib_chr("sourceName"),
            tib_chr("sourceConfirmedIndicator"),
            tib_df(
              "associatedCauseNames",
              tib_chr("causeName"),
            ),
          ),
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
            tib_chr("documentDescription"),
            tib_chr("documentComments"),
            tib_chr("documentURL"),
          ),
          tib_chr("rationaleText"),
          tib_chr("epaIRCategory"),
          tib_chr("overallStatus"),
          tib_chr("cycleLastAssessedText"),
          tib_chr("yearLastMonitoredText"),
        ),
        tib_df(
          "delistedWaters",
          tib_chr("assessmentUnitIdentifier"),
          tib_df(
            "delistedWaterCauses",
            tib_chr("causeName"),
            tib_chr("agencyCode"),
            tib_chr("delistingReasonCode"),
            tib_chr("delistingCommentText"),
          ),
        ),
      ),
      tib_int("count"),
    )
  }
  if(exclude_assessments == "Y") {
    spec <- tspec_object(
      tib_df(
        "items",
        tib_chr("organizationIdentifier"),
        tib_chr("organizationName"),
        tib_chr("organizationTypeText"),
        tib_chr("reportingCycleText"),
        tib_unspecified("combinedCycles"),
        tib_chr("reportStatusCode"),
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
        tib_unspecified("assessments"),
        tib_unspecified("delistedWaters"),
      ),
      tib_int("count"),
    )
  }
  return(spec)

}

