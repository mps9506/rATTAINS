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
#' @param .unnest (logical) \code{TRUE} (default) the function attempts to unnest
#'   data to longest format possible. This defaults to \code{TRUE} for backwards
#'   compatibility but it is suggested to use \code{FALSE}.
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
                             .unnest = TRUE,
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
  con_check <- check_connectivity()
  if(!isTRUE(con_check)){
    return(invisible(NULL))
  }

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
         x = list(tidy, .unnest),
         .var.name = c("tidy", ".unnest"),
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

  ## download data
  content <- xGET(path,
                  args,
                  file = NULL,
                  ...)

  if(is.null(content)) return(content)

  if (!isTRUE(tidy)) {
    return(content)
  } else {
   json_list <- jsonlite::fromJSON(content,
      simplifyVector = TRUE,
      simplifyDataFrame = TRUE,
      flatten = FALSE)
    
    content <- as_tibble(json_list)
 
    ## if unnest = FALSE do not unnest lists
    if(!isTRUE(.unnest)) {
      return(content)
    }
    
    items <- unnest(content, "items")  
    
    ## create first tibble
    content_item_summary <- select(items, !where(is.list))
    content_names <- select(items, where(is.list))
    content_names <- as.list(names(content_names))
    list_content <- list(itemSummary = content_item_summary)
    
    output_list <- map(content_names,
      function(x) {
        y <- unnest(content, "items")
        y <- select(y, all_of(x))
        y <- unnest(y, cols = everything())
      })
    names(output_list) <- unlist(content_names)
    return(append(list_content, output_list))
    }
}
