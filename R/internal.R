
#' xGET
#'
#' Internal function for making http requests.
#' @param path character
#' @param args query argument list
#' @param ... curl options passed to crul::HttpClient
#'
#' @return parsed JSON I think.
#' @export
#' @importFrom crul HttpClient
#' @keywords internal
#' @noRd
xGET <- function(path, args = list(), ...) {
  url <- "https://attains.epa.gov"
  cli <- crul::HttpClient$new(url,
                              opts = list(...))
  res <- cli$get(path = path,
                 query = args)

  errs(res)

  content <- res$parse("UTF-8")
  attr(content, 'url') <- res$url

  return(content)
}

#' Gracefully return http errors
#'
#' Internal function for returning http error message when making http requests.
#' @param x http request
#'
#' @return error message or nothing
#' @export
#' @keywords internal
#' @noRd
#' @importFrom fauxpas find_error_class
errs <- function(x) {
  if (x$status_code > 201) {

    fun <- fauxpas::find_error_class(x$status_code)$new()
    fun$do_verbose(x)
  }
}
