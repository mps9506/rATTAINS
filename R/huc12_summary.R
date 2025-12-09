#' Download HUC12 Summary
#'
#' @description Provides summary data for a 12-digit Hydrologic Unit Code
#'   (HUC12), based on Assessment Units in the HUC12. Watershed boundaries may
#'   cross state boundaries, so the service may return assessment units from
#'   multiple organizations. Returns the assessment units in the HUC12, size and
#'   percentages of assessment units considered Good, Unknown, or Impaired.
#'
#' @param huc (character) Specifies the 12-digit HUC to be summarized. required
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied
#'   tibble. \code{FALSE} the function returns the raw JSON string.
#' @param .unnest (logical) \code{TRUE} (default) the function attempts to unnest
#'   data to longest format possible. This defaults to \code{TRUE} for backwards
#'   compatibility but it is suggested to use \code{FALSE}.
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return If \code{tidy = FALSE} the raw JSON string is returned, else the JSON
#'   data is parsed and returned as a list of tibbles that include a list of
#'   seven tibbles.
#' @note See [domain_values] to search values that can be queried.
#' @export
#' @examples
#'
#' \dontrun{
#' ## Return a list of tibbles with summary data about a single huc12
#' x <- huc12_summary(huc = "020700100204")
#'
#' ## Return as a JSON string
#' x <- huc12_summary(huc = "020700100204", tidy = FALSE)
#' }
huc12_summary <- function(huc,
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
         x = list(huc),
         .var.name = c("huc"),
         MoreArgs = list(null.ok = FALSE,
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

  args <- list(huc = huc)
  path = "attains-public/api/huc12summary"

  ## download data
  content <- xGET(path,
                  args,
                  file = NULL,
                  ...)

  if(is.null(content)) return(content)

  if(!isTRUE(tidy)) {
    return(content)
  } else {

    ## parse JSON
    json_list <- jsonlite::fromJSON(content,
                                    simplifyVector = TRUE,
                                    simplifyDataFrame = TRUE,
                                    flatten = FALSE)
    
    content <- as_tibble(json_list)
    
    ## if unnest = FALSE do not unnest lists
    if(!isTRUE(.unnest)) {
      return(content)
    }
    
    ## create separate tibbles to return as list
    items <- unnest(content, "items")  

    ## create first tibble
    content_huc_summary <- select(items, !where(is.list))
  
    ## create list of tibble names used to assign names in the future list
    content_names <- select(items, where(is.list))
    content_names <- as.list(names(content_names))

    list_content <- list(hucSummary = content_huc_summary)

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
