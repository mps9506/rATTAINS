#' Download State Summaries
#'
#' @description  Provides summary information for assessed uses for an organization (State,
#' Territory or Tribe) and Integrated Reporting Cycle. The Organization ID for
#' the state, territory or tribe is required. If a Reporting Cycle isn't
#' provided, the service will return the most recent cycle. If a reporting Cycle
#' is provided, the service will return a summary for the requested cycle.
#'
#' @param organization_id (character) Restricts results to the specified
#'   organization. required
#' @param reporting_cycle (character) Filters the returned results to the
#'   specified 4 digit reporting cycle year. Typically even numbered years. Will
#'   return reporting data for all years prior to and including the reporting
#'   cycle by reporting cycle. optional
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied
#'   tibble. \code{FALSE} the function returns the raw JSON string.
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return If \code{tidy = FALSE} the raw JSON string is
#'   returned, else the JSON data is parsed and returned as a list of tibbles.
#' @note See [domain_values] to search values that can be queried.
#' @import tibblify
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
#' @importFrom fs path
#' @importFrom janitor clean_names
#' @importFrom jsonlite fromJSON
#' @importFrom rlang is_empty .data
#' @importFrom rlist list.filter
#' @importFrom tidyr unnest
#' @importFrom tidyselect everything
#' @export
#' @examples
#'
#' \dontrun{
#' ## Get a list of tibbles summarizing assessed uses
#' state_summary(organization_id = "TDECWR", reporting_cycle = "2016")
#'
#' ## Returns the query as a JSON string instead
#' state_summary(organization_id = "TDECWR", reporting_cycle = "2016", tidy = FALSE)
#' }
#'
state_summary <- function(organization_id = NULL,
                          reporting_cycle = NULL,
                          tidy = TRUE,
                          ...) {

  ## check connectivity
  check_connectivity()

  ## check that arguments are character
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_character,
         x = list(organization_id, reporting_cycle),
         .var.name = c("organization_id", "reporting_cycle"),
         MoreArgs = list(null.ok = TRUE,
                         add = coll))
  checkmate::reportAssertions(coll)


  ## check that required args are present
  args <- list(organizationId = organization_id,
               reportingCycle = reporting_cycle)
  args <- list.filter(args, !is.null(.data))
  required_args <- c("organizationId")
  args_present <- intersect(names(args), required_args)
  if(is_empty(args_present)) {
    stop("One of the following arguments must be provided: organization_id")
  }
  path <- "attains-public/api/usesStateSummary"

  ## download data without caching
  content <- xGET(path,
                  args,
                  file = NULL,
                  ...)


  if(is.null(content)) return(content)

  if(!isTRUE(tidy)) { ## return raw data
    return(content)
  } else {## return parsed data

    ## parse json
    json_list <- jsonlite::fromJSON(content,
                                    simplifyVector = FALSE,
                                    simplifyDataFrame = FALSE,
                                    flatten = FALSE)

    ## create tibblify specification
    spec <- spec_state_summary()

    ## nested list -> rectangular data
    content <- tibblify(json_list$data,
                        spec = spec,
                        unspecified = "drop")

    content <- unnest(content, cols = everything(), keep_empty = TRUE)
    content <- unnest(content, cols = everything(), keep_empty = TRUE)
    content <- unnest(content, cols = everything(), keep_empty = TRUE)
    content <- unnest(content, cols = everything(), keep_empty = TRUE)
    content <- clean_names(content)

    return(content)
  }

}


#' Create tibblify specification for state_summary
#' @return tibblify specification
#' @keywords internal
#' @noRd
#' @import tibblify
spec_state_summary <- function() {
  spec <- tspec_row(
    tib_chr("organizationIdentifier"),
    tib_chr("organizationName"),
    tib_chr("organizationTypeText"),
    tib_df(
      "reportingCycles",
      tib_chr("reportingCycle"),
      tib_unspecified("combinedCycles"),
      tib_df(
        "waterTypes",
        tib_chr("waterTypeCode"),
        tib_chr("unitsCode"),
        tib_df(
          "useAttainments",
          tib_chr("useName"),
          tib_dbl("Fully Supporting", required = FALSE),
          tib_int("Fully Supporting-count", required = FALSE),
          tib_dbl("Not Assessed", required = FALSE),
          tib_int("Not Assessed-count", required = FALSE),
          tib_dbl("Not Supporting", required = FALSE),
          tib_int("Not Supporting-count", required = FALSE),
          tib_df(
            "parameters",
            tib_chr("parameterGroup", required = FALSE),
            tib_dbl("Cause", required = FALSE),
            tib_int("Cause-count", required = FALSE),
          ),
          tib_dbl("Insufficient Information", required = FALSE),
          tib_int("Insufficient Information-count", required = FALSE),
        ),
      ),
    ),
  )
  }
