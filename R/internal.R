
#' xGET
#'
#' Internal function for making http requests.
#' @param path character
#' @param args query argument list
#' @param file character file path to cache file
#' @param ... curl options passed to crul::HttpClient
#'
#' @return parsed JSON I think.
#' @importFrom crul HttpClient
#' @keywords internal
#' @noRd
xGET <- function(path, args = list(), file = NULL, ...) {
  url <- "https://attains.epa.gov"
  cli <- crul::HttpClient$new(url,
                              opts = list(...))

  full_url <- cli$url_fetch(path = path,
                            query = args)

  res <- cli$retry("GET",
                   path = path,
                   query = args,
                   pause_base = 5,
                   pause_cap = 60,
                   pause_min = 5,
                   times = 3,
                   terminate_on = c(404),
                   ...)

  errs(res)

  if (!is.null(res)) {
    content <- res$parse("UTF-8")
  } else {
    content <- NULL
    warning("Sorry, no data found", call. = FALSE)
  }



  return(content)
}

#' Gracefully return http errors
#'
#' Internal function for returning http error message when making http requests.
#' @param x http request
#'
#' @return error message or nothing
#' @keywords internal
#' @noRd
#' @importFrom fauxpas find_error_class
errs <- function(x) {
  if (x$status_code > 201) {

    fun <- fauxpas::find_error_class(x$status_code)$new()
    fun$do(x)
  }
}



#' Check connectivity
#'
#' @return TRUE or error
#' @keywords internal
#' @noRd
#' @importFrom curl nslookup
check_connectivity <- function() {
  tryCatch(expr = {
    nslookup("attains.epa.gov")
    return(TRUE)
    },
    error = function(e){
      message("No connection to <https://attains.epa.gov> available!")
    }
  )
}

