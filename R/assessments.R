#' Download Assessment Decisions
#'
#' @param assessment_unit_id (character) Specify the specific assessment unit
#'   assessment data to return. Multiple values can be provided. optional
#' @param state_code (character) Filters returned assessments to those from the
#'   specified state. optional
#' @param organization_id (character) Filters the returned assessments to those
#'   belonging to the specified organization. optional
#' @param reporting_cycle (character) Filters the returned assessments to those
#'   for the specified reporting cycle. The reporting cycle refers to the
#'   four-digit year that the reporting cycle ended. Defaults to the current
#'   cycle. optional
#' @param use (character) Filters the returned assessments to those with the
#'   specified uses. Multiple values can be provided. optional
#' @param use_support (character) Filters returned assessments to those fully
#'   supporting the specified uses or that are threatened. Multiple values can
#'   be provided. Allowable values include \code{"X"}= Not Assessed, \code{"I"}=
#'   Insufficient Information, \code{"F"}= Fully Supporting, \code{"N"}= Not
#'   Supporting, and \code{"T"}= Threatened. optional
#' @param parameter (character) Filters the returned assessments to those with
#'   one or more of the specified parameters. Multiple values can be provided.
#'   optional
#' @param parameter_status_name (character) Filters the returned assessments to
#'   those with one or more associated parameters meeting the provided value.
#'   Valid values are \code{"Meeting Criteria"}, \code{"Cause"}, \code{"Observed
#'   Effect"}. Multiple valuse can be provided. optional
#' @param probable_source (character) Filters the returned assessments to those
#'   having the specified probable source. Multiple values can be provided.
#'   optional
#' @param agency_code (character) Filters the returned assessments to those by
#'   the type of agency responsible for the assessment. Allowed values are
#'   \code{"E"}=EPA, \code{"S"}=State, \code{"T"}=Tribal. optional
#' @param ir_category (character) Filters the returned assessments to those
#'   having the specified IR category. Multiple values can be provided. optional
#' @param state_ir_category_code (character) Filters the returned assessments to
#'   include those having the provided codes.
#' @param multicategory_search (character) Specifies whether to search at
#'   multiple levels.  If this parameter is set to “Y” then the query applies
#'   the EPA IR Category at the Assessment, UseAttainment, and Parameter levels;
#'   if the parameter is set to “N” it looks only at the Assessment level.
#' @param last_change_later_than_date (character) Filters the returned
#'   assessments to only those last changed after the provided date. Must be a
#'   character with format: \code{"yyyy-mm-dd"}. optional
#' @param last_change_earlier_than_date (character) Filters the returned
#'   assessments to only those last changed before the provided date. Must be a
#'   character with format: \code{"yyyy-mm-dd"}. optional
#' @param return_count_only `r lifecycle::badge("deprecated")`
#'   `return_count_only = TRUE` is no longer supported.
#' @param exclude_assessments (logical) If \code{TRUE} returns only the
#'   documents associated with the Assessment cycle instead of the assessment
#'   data. Defaults is \code{FALSE}.
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
#' @return If \code{tidy = FALSE} the raw JSON string is returned, else the JSON
#'   data is parsed and returned as tibbles.
#' @note See [domain_values] to search values that can be queried. In v1.0.0
#'   rATTAINS returns a list of tibbles (`documents`, `use_assessment`,
#'   `delisted_waters`). Prior versions returned `documents`, `use_assessment`,
#'   and `parameter_assessment`.
#' @export
#' @importFrom checkmate assert_character assert_logical makeAssertCollection
#'   reportAssertions
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
         x = list(return_count_only, exclude_assessments, tidy, .unnest),
         .var.name = c("return_count_only", "exclude_assessments", "tidy",
                       ".unnest"),
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
                                     exclude_assessments = exclude_assessments,
                                     .unnest = .unnest)

    return(content)
  }
}


#'
#' @param content raw JSON
#' @param count logical
#' @param exclude_assessments "Y" or "N"
#' @param .unnest logical
#'
#' @noRd
#' @import tibblify
#' @importFrom dplyr select
#' @importFrom jsonlite fromJSON
#' @importFrom tidyr unnest
#' @importFrom tidyselect everything
assessments_to_tibble <- function(content,
                                  count = FALSE,
                                  exclude_assessments,
                                  .unnest) {
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

  ## if unnest = FALSE do not unnest lists
  if(!isTRUE(.unnest)) {
    return(content$items)
  }

  if(exclude_assessments == "N") {

    content_documents <- select(content$items, -c("assessments", "delisted_waters"))
    content_documents <- unnest(content_documents, cols = everything(), keep_empty = TRUE)
    content_documents <- unnest(content_documents, cols = everything(), keep_empty = TRUE)


    content_assessments <- select(content$items, -c("documents", "delisted_waters"))
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
      "items" = tib_df(
        "items",
        "organization_identifier" = tib_chr("organizationIdentifier", required = FALSE),
        "organization_name" = tib_chr("organizationName", required = FALSE),
        "organization_type_text" = tib_chr("organizationTypeText", required = FALSE),
        "reporting_cycle_text" = tib_chr("reportingCycleText", required = FALSE),
        "combined_cycles" = tib_unspecified("combinedCycles", required = FALSE),
        "report_status_code" = tib_chr("reportStatusCode", required = FALSE),
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
          "document_description" = tib_chr("documentDescription", required = FALSE),
          "document_comments" = tib_chr("documentComments", required = FALSE),
          "document_url" = tib_chr("documentURL", required = FALSE),
        ),
        "assessments" = tib_df(
          "assessments",
          "assessment_unit_identifier" = tib_chr("assessmentUnitIdentifier", required = FALSE),
          "agency_code" = tib_chr("agencyCode", required = FALSE),
          "trophic_status_code" = tib_chr("trophicStatusCode", required = FALSE),
          "use_attainments" = tib_df(
            "useAttainments",
            "use_name" = tib_chr("useName", required = FALSE),
            "use_attainment_code" = tib_chr("useAttainmentCode", required = FALSE),
            "threatened_indicator" =tib_chr("threatenedIndicator", required = FALSE),
            "trend_code" = tib_chr("trendCode", required = FALSE),
            "agency_code" = tib_chr("agencyCode", required = FALSE),
            "assessment_metadata" = tib_row(
              "assessmentMetadata",
              "assessment_basis_code" = tib_chr("assessmentBasisCode", required = FALSE),
              "assessment_types" = tib_df(
                "assessmentTypes",
                .required = FALSE,
                "assessment_type_code" = tib_chr("assessmentTypeCode", required = FALSE),
                "assessment_confidence_code" = tib_chr("assessmentConfidenceCode", required = FALSE),
              ),
              "assessment_method_types" = tib_df(
                "assessmentMethodTypes",
                .required = FALSE,
                "method_type_context" = tib_chr("methodTypeContext", required = FALSE),
                "method_type_code" = tib_chr("methodTypeCode", required = FALSE),
                "method_type_name" = tib_chr("methodTypeName", required = FALSE),
              ),
              "monitoring_activity" = tib_row(
                "monitoringActivity",
                .required = FALSE,
                "monitoring_start_date" = tib_chr("monitoringStartDate", required = FALSE),
                "monitoring_end_date" = tib_chr("monitoringEndDate", required = FALSE),
              ),
              "assessment_activity" = tib_row(
                "assessmentActivity",
                .required = FALSE,
                "assessment_date" = tib_chr("assessmentDate", required = FALSE),
                "assessor_name" = tib_chr("assessorName", required = FALSE),
              ),
            ),
            "use_attainment_code_name" = tib_chr("useAttainmentCodeName", required = FALSE),
          ),
          "parameters" = tib_df(
            "parameters",
            "parameter_status_name" = tib_chr("parameterStatusName", required = FALSE),
            "parameter_name" = tib_chr("parameterName", required = FALSE),
            "associated_uses" = tib_df(
              "associatedUses",
              "associated_use_name" = tib_chr("associatedUseName", required = FALSE),
              "parameter_attainment_code" = tib_chr("parameterAttainmentCode", required = FALSE),
              "trend_code" = tib_chr("trendCode", required = FALSE),
              "seasons" = tib_df("seasons"),
            ),
            "impaired_waters_information" = tib_df(
              "impairedWatersInformation",
              .names_to = ".names",
              "agency_code" = tib_chr("agencyCode", required = FALSE),
              "cycle_first_listed_text" = tib_chr("cycleFirstListedText", required = FALSE),
              "cycle_scheduled_for_TMDL_text" = tib_chr("cycleScheduledForTMDLText", required = FALSE),
              "CWA_303d_priority_ranking_text" = tib_chr("CWA303dPriorityRankingText", required = FALSE),
              "consent_decree_cycle_text" = tib_chr("consentDecreeCycleText", required = FALSE),
              "alternate_listing_identifier" = tib_unspecified("alternateListingIdentifier", required = FALSE),
              "cycle_expected_to_attain" = tib_chr("cycleExpectedToAttain", required = FALSE),
            ),
            "associated_actions" = tib_df(
              "associatedActions",
              "associated_action_identifier" = tib_chr("associatedActionIdentifier", required = FALSE),
            ),
            "pollutant_indicator" = tib_chr("pollutantIndicator", required = FALSE),
          ),
          "probable_sources" = tib_df(
            "probableSources",
            "source_name" = tib_chr("sourceName", required = FALSE),
            "source_confirmed_indicator" = tib_chr("sourceConfirmedIndicator", required = FALSE),
            "associated_casue_names" = tib_df(
              "associatedCauseNames",
              "cause_name" = tib_chr("causeName", required = FALSE),
            ),
          ),
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
            "document_description" = tib_chr("documentDescription", required = FALSE),
            "document_comments" = tib_chr("documentComments", required = FALSE),
            "document_url" = tib_chr("documentURL", required = FALSE),
          ),
          "rationale_text" = tib_chr("rationaleText", required = FALSE),
          "EPA_IR_category" = tib_chr("epaIRCategory", required = FALSE),
          "overall_status" = tib_chr("overallStatus", required = FALSE),
          "cycle_last_assessed_text" = tib_chr("cycleLastAssessedText", required = FALSE),
          "year_last_monitored_text" = tib_chr("yearLastMonitoredText", required = FALSE),
        ),
        "delisted_waters" = tib_df(
          "delistedWaters",
          "assessment_unit_identifier" = tib_chr("assessmentUnitIdentifier", required = FALSE),
          "delisted_water_causes" = tib_df(
            "delistedWaterCauses",
            "delisiting_cause_name" = tib_chr("causeName", required = FALSE),
            "delisting_agency_code" = tib_chr("agencyCode", required = FALSE),
            "delisting_reason_code" = tib_chr("delistingReasonCode", required = FALSE),
            "delisting_comment_text" = tib_chr("delistingCommentText", required = FALSE),
          ),
        ),
      ),
      "count" = tib_int("count", required = FALSE),
    )
  }
  if(exclude_assessments == "Y") {
    spec <- tspec_object(
      "items" = tib_df(
        "items",
        "organization_identifier" = tib_chr("organizationIdentifier"),
        "organization_name" = tib_chr("organizationName"),
        "organization_type_text" = tib_chr("organizationTypeText"),
        "reporting_cycle_text" = tib_chr("reportingCycleText"),
        "combined_cycles" = tib_unspecified("combinedCycles"),
        "report_Status_code" = tib_chr("reportStatusCode"),
        "documents" = tib_df(
          "documents",
          "agency_code" = tib_chr("agencyCode"),
          "document_types" = tib_df(
            "documentTypes",
            "document_type_code" = tib_chr("documentTypeCode"),
          ),
          "document_file_type" = tib_chr("documentFileType"),
          "document_file_name" = tib_chr("documentFileName"),
          "document_name" = tib_chr("documentName"),
          "document_description" = tib_unspecified("documentDescription"),
          "document_comments" = tib_chr("documentComments"),
          "document_url" = tib_chr("documentURL"),
        ),
        "assessments" = tib_unspecified("assessments"),
        "delisted_waters" = tib_unspecified("delistedWaters"),
      ),
      "count" = tib_int("count"),
    )
  }
  return(spec)

}

