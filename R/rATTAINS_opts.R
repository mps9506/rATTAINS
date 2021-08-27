rATTAINSenv <- new.env()
rATTAINSenv$cache_downloads <- FALSE

#' rATTAINS options
#' @export
#' @param cache_downloads (logical) whether to locally cache downloads. default: `FALSE`
#' @details rATTAINS package level options; stored in an internal
#' package environment `rATTAINSenv`
#' @seealso [rATTAINS_caching] for managing cached files
#' @examples \dontrun{
#' rATTAINS_options(cache_downloads = FALSE)
#' }
#' @return \value{None}
rATTAINS_options <- function(cache_downloads = FALSE) {
  rATTAINSenv$cache_downloads <- cache_downloads
  return(NULL)
}
