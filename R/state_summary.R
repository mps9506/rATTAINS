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
#' @param .unnest (logical) \code{TRUE} (default) the function attempts to unnest
#'   data to longest format possible. This defaults to \code{TRUE} for backwards
#'   compatibility but it is suggested to use \code{FALSE}.
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return If \code{tidy = FALSE} the raw JSON string is
#'   returned, else the JSON data is parsed and returned as a list of tibbles.
#' @note See [domain_values] to search values that can be queried.
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
state_summary <- function(
  organization_id = NULL,
  reporting_cycle = NULL,
  tidy = TRUE,
  .unnest = TRUE,
  ...
) {
  ## check connectivity
  con_check <- check_connectivity()
  if (!isTRUE(con_check)) {
    return(invisible(NULL))
  }

  ## check that arguments are character
  coll <- checkmate::makeAssertCollection()
  mapply(
    FUN = checkmate::assert_character,
    x = list(organization_id, reporting_cycle),
    .var.name = c("organization_id", "reporting_cycle"),
    MoreArgs = list(null.ok = TRUE, add = coll)
  )
  checkmate::reportAssertions(coll)

  ## check logical
  coll <- checkmate::makeAssertCollection()
  mapply(
    FUN = checkmate::assert_logical,
    x = list(tidy, .unnest),
    .var.name = c("tidy", ".unnest"),
    MoreArgs = list(null.ok = FALSE, add = coll)
  )
  checkmate::reportAssertions(coll)

  ## check that required args are present
  args <- list(
    organizationId = organization_id,
    reportingCycle = reporting_cycle
  )
  args <- list.filter(args, !is.null(.data))
  required_args <- c("organizationId")
  args_present <- intersect(names(args), required_args)
  if (is_empty(args_present)) {
    stop("One of the following arguments must be provided: organization_id")
  }
  path <- "attains-public/api/usesStateSummary"

  ## download data
  content <- xGET(path, args, file = NULL, ...)

  if (is.null(content)) {
    return(content)
  }

  if (!isTRUE(tidy)) {
    ## return raw data
    return(content)
  } else {
    ## return parsed data

    ## parse json
    json_list <- jsonlite::fromJSON(
      content,
      simplifyVector = TRUE,
      simplifyDataFrame = TRUE,
      flatten = FALSE
    )

    df <- as_tibble(json_list$data)
    df <- unnest_wider(df, "reportingCycles")
    df <- unnest(df, c("combinedCycles", "waterTypes"))
    df <- unnest(df, c("waterTypes"))
    df <- unnest(df, c("useAttainments"))

    ## if unnest == FALSE do not unnest lists
    if (!isTRUE(.unnest)) {
      content <- list(
        items = df
      )
      return(content)
    } else {
      df <- tryCatch(
        unnest(df, cols = everything(), keep_empty = TRUE),
        error = function(e) {
          df
        },
        finally = message(
          "Unable to further unnest data, check for nested dataframes."
        )
      )
      content <- list(
        items = df
      )
      return(content)
    }
  }
}
