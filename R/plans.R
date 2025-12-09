#' Download Plans and Actions by HUC
#' @description Returns information about plans or actions (TMDLs, 4B Actions,
#'   Alternative Actions, Protective Approach Actions) that have been finalized.
#'   This is similar to [actions] but returns data by HUC code and any
#'   assessment units covered by a plan or action within the specified HUC.
#' @param huc (character) Filters the returned actions by 8-digit or higher HUC.
#'   required
#' @param organization_id (character). Filters the returned actions by those
#'   belonging to the specified organization. Multiple values can be used.
#'   optional
#' @param summarize (logical) If \code{TRUE} the count of assessment units is
#'   returned rather than the assessment unit itdentifers for each action.
#'   Defaults to \code{FALSE}.
#' @param tidy (logical) \code{TRUE} (default) the function returns a list of
#'   tibbles. \code{FALSE} the function returns the raw JSON string.
#' @param .unnest (logical) \code{TRUE} (default) the function attempts to unnest
#'   data to longest format possible. This defaults to \code{TRUE} for backwards
#'   compatibility but it is suggested to use \code{FALSE}.
#' @param ... list of curl options passed to [crul::HttpClient()]
#' @details \code{huc} is a required argument. Multiple values are allowed for
#'   indicated arguments and should be included as a comma separated values in
#'   the string (eg. \code{organization_id="TCEQMAIN,DCOEE"}).
#' @return If \code{count = TRUE} returns a tibble that summarizes the count of
#'   actions returned by the query. If \code{count = FALSE} returns a list of
#'   tibbles including documents, use assessment data, and parameters assessment
#'   data identified by the query. If \code{tidy = FALSE} the raw JSON string is
#'   returned, else the JSON data is parsed and returned as a list of tibbles.
#' @note See [domain_values] to search values that can be queried. As of v1.0
#'   this function no longer returns the `documents`, `associated_permits`, or
#'   `plans` tibbles.
#' @export
#' @examples
#'
#' \dontrun{
#'
#' ## Query plans by huc
#' plans(huc ="020700100103")
#'
#' ## return a JSON string instead of list of tibbles
#' plans(huc = "020700100103", tidy = FALSE)
#' }
plans <- function(huc,
                  organization_id = NULL,
                  summarize = FALSE,
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
         x = list(huc, organization_id),
         .var.name = c("huc", "organization_id"),
         MoreArgs = list(null.ok = TRUE,
                         add = coll))
  checkmate::reportAssertions(coll)

  ## check logical
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_logical,
         x = list(summarize, tidy, .unnest),
         .var.name = c("summarize", "tidy", ".unnest"),
         MoreArgs = list(null.ok = TRUE,
                         add = coll))
  checkmate::reportAssertions(coll)

  summarize <- if(isTRUE(summarize)) {
    "Y"
  } else {"N"}

  args <- list(huc = huc,
               oganizationId = organization_id,
               summarize = summarize)
  args <- list.filter(args, !is.null(.data))
  required_args <- c("huc")
  args_present <- intersect(names(args), required_args)
  if(is_empty(args_present)) {
    stop("One of the following arguments must be provided: huc")
  }

  path = "attains-public/api/plans"

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
