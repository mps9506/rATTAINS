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
#' @param return_count_only (character) "Y" for yes, "N" for no. Defaults to
#'   "N". optional
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
#' @import tidyjson
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
#' @importFrom dplyr mutate select
#' @importFrom fs path
#' @importFrom janitor clean_names
#' @importFrom purrr map
#' @importFrom rlist list.filter
#' @importFrom rlang is_empty .data
#' @importFrom tibble tibble as_tibble
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
                  returnCountOnly = return_count_only)
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
    content <- content %>%
      enter_object("items") %>%
      gather_array() %>%
      spread_all() %>%
      select(-c(.data$document.id, .data$array.index)) %>%
      enter_object("assessmentUnits") %>%
      gather_array() %>%
      spread_all(recursive = TRUE) %>%
      select(-c(.data$array.index)) %>%
      ## this is slow as heck
      ## but not sure how else to consistently return empty lists
      ## without errors.
      mutate(
        locations = map(.data$..JSON, ~{
          .x[["locations"]] %>% {
            tibble(
              locationTypeCode = map(., "locationTypeCode"),
              locationText = map(., "locationText")
            )} %>%
            clean_names()
        }),
        waterTypes = map(.data$..JSON, ~{
          .x[["waterTypes"]] %>% {
            tibble(
              waterTypeCode = map(., "waterTypeCode"),
              waterSizeNumber = map(., "waterSizeNumber"),
              unitsCode = map(., "unitsCode"),
              sizeEstimationMethod = map(., "SizeEstimationMethod"),
              sizeSourceText = map(., "sizeSourceText"),
              sizeSourceScaleText = map(., "sizeSourceScaleText")
            )} %>%
            clean_names()
        })
      ) %>%
      as_tibble() %>%
      clean_names()

    return(content)
  }
}
