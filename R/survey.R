#' Download State Survey Results
#'
#' @description Downloads data about state statistical (probability) survey results.
#' @param organization_id (character) Filters the list to only those “belonging
#'   to” one of the specified organizations. Multiple values may be specified.
#'   required
#' @param survey_year (character) Filters the list to the year the survey was
#'   performed. optional.
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied
#'   tibble. \code{FALSE} the function returns the raw JSON string.
#' @param .unnest (logical) \code{TRUE} (default) the function attempts to unnest
#'   data to longest format possible. This defaults to \code{TRUE} for backwards
#'   compatibility but it is suggested to use \code{FALSE}.
#' @param ... list of curl options passed to [crul::HttpClient()]
#' @return If \code{tidy = FALSE} the raw JSON string is
#'   returned, else the JSON data is parsed and returned as a list of tibbles.
#' @details Arguments that allow multiple values should be entered as a comma
#'   separated string with no spaces (\code{organization_id = "DOEE,21AWIC"}).
#' @note See [domain_values] to search values that can be queried.
#' @export
#' @examples
#'
#' \dontrun{
#'
#' ## return surveys by organization
#' surveys(organization_id="SDDENR")
#'
#' ## return as a JSON string instead of a list of tibbles
#' surveys(organization_id="SDDENR", tidy = FALSE)
#' }

surveys <- function(organization_id = NULL,
                    survey_year = NULL,
                    tidy = TRUE,
                    .unnest = TRUE,
                    ...) {

  ## check connectivity
  con_check <- check_connectivity()
  if(!isTRUE(con_check)){
    return(invisible(NULL))
  }

  ## check that arguments are character
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_character,
         x = list(organization_id, survey_year),
         .var.name = c("organization_id", "survey_year"),
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
  args <- list(organizationId = organization_id,
               surveyYear = survey_year)
  args <- list.filter(args, !is.null(.data))
  required_args <- c("organizationId")
  args_present <- intersect(names(args), required_args)
  if(is_empty(args_present)) {
    stop("One of the following arguments must be provided: organization_id")
  }

  path = "attains-public/api/surveys"

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

    ## parse JSON
    json_list <- fromJSON(content,
                          simplifyVector = TRUE,
                          simplifyDataFrame = TRUE,
                          flatten = FALSE)
    
    df <- as_tibble(json_list$items)
    df <- unnest_wider(df, "surveys") 
    df <- unnest(df, c("surveyStatusCode", "year", "surveyCommentText", "documents", "surveyWaterGroups"))

    ## if unnest == FALSE do not unnest lists
    if(!isTRUE(.unnest)) {
      content <- list(
        count = tibble(count = json_list$count),
        items = df
      )
      return(content)
    }
    
    df <- tryCatch(
        unnest(df, cols = everything(), keep_empty = TRUE),
        error = function(e) {df},
        finally = message("Unable to further unnest data, check for nested dataframes.")
       )
    
    content <- list(
        count = tibble(count = json_list$count),
        items = df
      )
    return(content)
  }
}


