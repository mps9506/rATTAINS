#' Download Assessment Unit Summary
#' @description Provides basic information about the requested assessment units.
#' @param assessment_unit_identifer (character) Filters returned assessment
#'   units to one or more specific assessment units. Multiple values can be
#'   provided. optional
#' @param state_code (character) Filters returned assessment units to only
#'   those having a state code matches one in the provided list of states.
#'   Multiple values can be provided. optional
#' @param organization_id (character) Filters returned assessment units to only
#'   those having a mathcing organization ID. Multiple values can be provided.
#'   optional
#' @param epa_region (character) Filters returned assessment units to only
#'   matching EPA regions. Multiple values can be provided. optional
#' @param huc (character) Filters returned assessment units to only those
#'   which have a location type of HUC and the location value matches the
#'   provided HUC. Multiple values can be provided. optional
#' @param county (character) Filters returned assessment units to only those
#'   which have a location type of county and matches the provided county.
#'   Multiple values can be provided. optional
#' @param assessment_unit_name (character) Filters the returned assessment units
#'   to matching the provided value.
#' @param last_change_later_than_date (character) Filters returned assessment
#'   units to those only changed after the provided date. Must be a character
#'   with format: \code{"yyyy-mm-dd"}. optional
#' @param last_change_earlier_than_date (character) Filters returned assessment
#'   units to those only changed before the provided date. Must be a character
#'   with format: \code{"yyyy-mm-dd"}. optional
#' @param status_indicator (character) Filter the returned assessment units to
#'   those with specified status. "A" for active, "R" for retired. optional
#' @param return_count_only `r lifecycle::badge("deprecated")`
#'   `return_count_only = Y` is no longer supported.
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied
#'   tibble. \code{FALSE} the function returns the raw JSON string.
#' @param ... list of curl options passed to [crul::HttpClient()]
#' @details One or more of the following arguments must be included:
#'   \code{assessment_unit_identfier}, \code{state_code} or
#'   \code{organization_id}. Multiple values are allowed for indicated arguments
#'   and should be included as a comma separated values in the string (eg.
#'   \code{organization_id="TCEQMAIN,DCOEE"}).
#' @return When \code{tidy = TRUE} a tibble with many variables, some nested, is
#'   returned. When \code{tidy=FALSE} a raw JSON string is returned.
#' @note See [domain_values] to search values that can be queried.
#' @export
#' @import tibblify
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
#' @importFrom fs path
#' @importFrom janitor clean_names
#' @importFrom jsonlite fromJSON
#' @importFrom lifecycle deprecate_warn
#' @importFrom rlist list.filter
#' @importFrom rlang is_empty .data
#' @importFrom tidyr unnest unpack
#' @importFrom tidyselect everything
#' @examples
#'
#' \dontrun{
#'
#' ## Retrieve data about a single assessment unit
#' assessment_units(assessment_unit_identifer = "AL03150201-0107-200")
#'
#' ## Retrieve data as a JSON instead
#' assessment_units(assessment_unit_identifer = "AL03150201-0107-200", tidy = FALSE)
#' }
assessment_units <- function(assessment_unit_identifer = NULL,
                             state_code = NULL,
                             organization_id = NULL,
                             epa_region = NULL,
                             huc = NULL,
                             county = NULL,
                             assessment_unit_name = NULL,
                             last_change_later_than_date = NULL,
                             last_change_earlier_than_date = NULL,
                             status_indicator = NULL,
                             return_count_only = NULL,
                             tidy = TRUE,
                             ...) {

  ## depreciate return_count_only
  if (!is.null(return_count_only)) {
    lifecycle::deprecate_warn(
      when = "1.0.0",
      what = "actions(return_count_only)",
      details = "Ability to retun counts only is depreciated and defaults to
      NULL. The `return_count_only` argument will be removed in future
      releases."
    )
  }

  ## check connectivity
  check_connectivity()

  ## check that arguments are character
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_character,
         x = list(assessment_unit_identifer, state_code, organization_id,
                  epa_region, huc, county, assessment_unit_name,
                  last_change_later_than_date, last_change_earlier_than_date,
                  status_indicator, return_count_only),
         .var.name = c("assessment_unit_identifer", "state_code", "organization_id",
                       "epa_region", "huc", "county", "assessment_unit_name",
                       "last_change_later_than_date", "last_change_earlier_than_date",
                       "status_indicator", "return_count_only"),
         MoreArgs = list(null.ok = TRUE,
                         add = coll))
  checkmate::reportAssertions(coll)

  ## check logical
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_logical,
         x = list(tidy),
         .var.name = c("tidy"),
         MoreArgs = list(null.ok = FALSE,
                         add = coll))
  checkmate::reportAssertions(coll)

  ## check that required args are present
  args <- list(assessmentUnitIdentifier = assessment_unit_identifer,
                  stateCode = state_code,
                  organizationId = organization_id,
                  epaRegion = epa_region,
                  HUC = huc,
                  county = county,
                  assessmentUnitName = assessment_unit_name,
                  lastChangeLaterThanDate = last_change_later_than_date,
                  lastChangeEarlierThanDate = last_change_earlier_than_date,
                  statusIndicator = status_indicator,
                  returnCountOnly = NULL) ## depreciated and defaults NULL
  args <- list.filter(args, !is.null(.data))
  required_args <- c("assessmentUnitIdentifier",
                     "stateCode",
                     "organizationId")
  args_present <- intersect(names(args), required_args)
  if(is_empty(args_present)) {
    stop("One of the following arguments must be provided: assessment_unit_identifer, state_code, or organization_id")
  }

  path <- "attains-public/api/assessmentUnits"

  ## download data without caching
  content <- xGET(path,
                  args,
                  file = NULL,
                  ...)

  if(is.null(content)) return(content)

  if (!isTRUE(tidy)) {
    return(content)
  } else {

    ## Parse JSON
    json_list <- jsonlite::fromJSON(content,
                                    simplifyVector = FALSE,
                                    simplifyDataFrame = FALSE,
                                    flatten = FALSE)

    ## Create tibblify specification
    spec <- spec_assessment_units()

    ## Created nested lists according to spec
    content <- tibblify(json_list,
                        spec = spec,
                        unspecified = "drop")

    ## list -> rectangle
    content <- unnest(content$items, cols = everything(), keep_empty = TRUE)
    content <- unnest(content, cols = "waterTypes", keep_empty = TRUE)
    content <- unpack(content, cols = everything())
    content <- clean_names(content)
    return(content)
    }
}

#' Create tibblify specification for assessment_units
#'
#' @return tibblify specification
#' @keywords internal
#' @noRd
#' @import tibblify
spec_assessment_units <- function() {
  spec <- tspec_object(
    tib_df(
      "items",
      tib_chr("organizationIdentifier", required = FALSE),
      tib_chr("organizationName", required = FALSE),
      tib_chr("organizationTypeText", required = FALSE),
      tib_df(
        "assessmentUnits",
        tib_chr("assessmentUnitIdentifier", required = FALSE),
        tib_chr("assessmentUnitName", required = FALSE),
        tib_chr("locationDescriptionText", required = FALSE),
        tib_chr("agencyCode", required = FALSE),
        tib_chr("stateCode", required = FALSE),
        tib_chr("statusIndicator", required = FALSE),
        tib_df(
          "waterTypes",
          tib_chr("waterTypeCode", required = FALSE),
          tib_dbl("waterSizeNumber", required = FALSE),
          tib_chr("unitsCode", required = FALSE),
          tib_chr("sizeEstimationMethodCode", required = FALSE),
          tib_chr("sizeSourceText", required = FALSE),
          tib_chr("sizeSourceScaleText", required = FALSE),
        ),
        tib_df(
          "locations",
          tib_chr("locationTypeCode", required = FALSE),
          tib_chr("locationText", required = FALSE),
        ),
        tib_df(
          "monitoringStations",
          tib_chr("monitoringOrganizationIdentifier", required = FALSE),
          tib_chr("monitoringLocationIdentifier", required = FALSE),
          tib_chr("monitoringDataLinkText", required = FALSE),
        ),
        tib_row(
          "useClass",
          tib_chr("useClassCode", required = FALSE),
          tib_chr("useClassName", required = FALSE),
        ),
        tib_df("documents"),
      ),
    ),
    tib_int("count", required = FALSE),
  )
}
