#' Download Assessment Unit Summary
#'
#' @param assessment_unit_identifer (character) Filters the list of assessment units to one or more specific assessment units. Multiple values can be provided.
#' @param state_code (character) Filters the list of assessment units to only those having a state code matches one in the provided list of states. Multiple values can be provided.
#' @param organization_id (character) Filters the list of assessment units to only those having an organization ID that matches one in the provided list of IDs. Multiple values can be provided.
#' @param epa_region (character) Filters the list of assessment units to only those having an EPA region that matches one in the provided list of regions. Multiple values can be provided.
#' @param huc (character) Filters the list of assessment units to only those which have a location type of HUC and the location value matches one in the provided list of HUCs. Multiple values can be provided.
#' @param county (character) Filters the list of assessment units to only those which have a location type of county and the location value matches one in the provided list of counties. Multiple values can be provided.
#' @param assessment_unit_name (character) Filters the list of assessment units to only those having an assessment unit name matching the provided value.
#' @param last_change_later_than_date (character) yyyy-mm-dd
#' @param last_change_earlier_than_date (character) yyyy-mm-dd
#' @param status_indicator (character) "A" for active, "R" for retired. optional
#' @param return_count_only (character) "Y" for yes, "N" for no. Defaults to "N". optional
#'
#' @return
#' @export
#' @importFrom janitor clean_names
#' @importFrom jsonlite fromJSON
#' @importFrom rlist list.filter
#' @importFrom rlang is_empty
#' @importFrom tibble enframe
#' @importFrom tidyr unnest_longer unnest_wider
#'
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
                             ...) {

  #args <- as.list(environment())
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
  args <- list.filter(args, !is.null(.))
  required_args <- c("assessmentUnitIdentifier",
                     "stateCode",
                     "organizationId")
  args_present <- intersect(names(args), required_args)
  if(is_empty(args_present)) {
    stop("One of the following arguments must be provided: assessment_unit_identifer, state_code, or organization_id")
  }
  path = "attains-public/api/assessmentUnits"
  content <- xGET(path, args, ...)

  ## parse the returned json
  content <- fromJSON(content, simplifyVector = FALSE)

  content <- content$items %>%
    enframe() %>%
    unnest_wider(value) %>%
    unnest_longer(assessmentUnits) %>%
    unnest_wider(assessmentUnits) %>%
    unnest_longer(waterTypes) %>%
    unnest_wider(waterTypes) %>%
    clean_names()


}
