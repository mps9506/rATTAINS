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
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied tibble. \code{FALSE} the function returns the raw JSON string.
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return When \code{tidy = TRUE} a tibble with many variables, some nested, is returned. When \code{tidy=FALSE} a raw JSON string is returned.
#' @export
#' @import tidyjson
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
#' @importFrom dplyr mutate select
#' @importFrom janitor clean_names
#' @importFrom purrr map
#' @importFrom rlist list.filter
#' @importFrom rlang is_empty .data
#' @importFrom tibble tibble as_tibble
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
                             tidy = TRUE,
                             ...) {

  ## check that arguments are character
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_character,
         x = list(assessment_unit_identifer, state_code, organization_id,
                  epa_region, huc, county, assessment_unit_name,
                  last_change_later_than_date, last_change_earlier_than_date,
                  status_indicator, return_count_only),
         .var.name = c("assessment_unit_identifer", "state_code",
                       "organization_id", "epa_region", "huc, county",
                       "assessment_unit_name", "last_change_later_than_date",
                       "last_change_earlier_than_date", "status_indicator",
                       "return_count_only"),
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

  ## setup file cache
  au_cache <- hoardr::hoard()
  path <- "attains-public/api/assessmentUnits"
  file <- file_key(path = path, arg_list = args)
  au_cache$cache_path_set(path = file)
  au_cache$mkdir()

  ## check if current results have been cached
  file_name <- file.path(au_cache$cache_path_get(),
                         "assessmentUnits.json")

  if(file.exists(file_name)) {
    message(paste0("reading cached file from: ", file_name))
    content <- readLines(file_name, warn = FALSE)
  } else {
    content <- xGET(path,
                    args,
                    file = file_name,
                    ...)
  }

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
