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
  url <- "https://api.epa.gov/attains"
  cli <- crul::HttpClient$new(
    url,
    opts = list(...),
    headers = list("X-API-Key" = Sys.getenv("RATTAINS_TOKEN"))
  )

  full_url <- cli$url_fetch(path = path, query = args)

  res <- cli$retry(
    "GET",
    path = path,
    query = args,
    pause_base = 5,
    pause_cap = 60,
    pause_min = 5,
    times = 3,
    terminate_on = c(404),
    ...
  )

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
    tryCatch(
      {
        fun <- fauxpas::find_error_class(x$status_code)$new()
        fun$do(x)
      },
      error = function(e) {
        NULL
      },
      finally = message(fun$mssg)
    )
  }
}


#' Check connectivity
#'
#' @return TRUE or error
#' @keywords internal
#' @noRd
#' @importFrom curl nslookup
check_connectivity <- function() {
  tryCatch(
    expr = {
      nslookup("attains.epa.gov")
      return(TRUE)
    },
    error = function(e) {
      message("No connection to <https://attains.epa.gov> available!")
    }
  )
}


#' Check API key
#'
#' Checks for API Key in current environment or provided by user.
#' Should be included near the top of each function before the arg list
#' is built.
#' @return TRUE or error
#' @keywords internal
#' @noRd
#'
check_api_key <- function() {
  tryCatch(
    expr = {
      ## RATTAINS_TOKEN
      ifelse(
        nchar(Sys.getenv("RATTAINS_TOKEN")) > 0,
        TRUE,
        FALSE
      )
      return(TRUE)
    },
    error = function(e) {
      message("API Token from Data.gov using: https://api.data.gov/signup/")
    }
  )
}
