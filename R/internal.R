
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

  tryCatch({
    res <- if(isTRUE(rATTAINSenv$cache_downloads)) {
      cli$retry("GET",
                path = path,
                disk = file,
                query = args,
                pause_base = 5,
                pause_cap = 60,
                pause_min = 5,
                terminate_on = c(404),
                ...)
      } else {
        cli$retry("GET",
                  path = path,
                  query = args,
                  pause_base = 5,
                  pause_cap = 60,
                  pause_min = 5,
                  terminate_on = c(404),
                  ...)
      }
    if (!res$success()) {
      stop(call. = FALSE)
      }
    },
    error = function(e) {
      e$message <-
        paste("Something went wrong with the query, no data were returned.",
              "Please see <https://attains.epa.gov> for potential server",
              "issues.\n")
      e$call <- NULL
      stop(e)
      }
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

    fun <- fauxpas::find_error_class(x$status_code)$new()
    fun$do_verbose(x)
  }
}



# returns the unique file path for the cached file
file_key <- function(arg_list, name) {
  if(length(arg_list) >= 1) {
    x <- paste0(arg_list, collapse = "_")
  } else {
    x <- ("_")
  }
  #x <- file.path(path, x)
  x <- paste0(x, name)
  x <- gsub(" ", "_", x, fixed = TRUE)
  return(x)
}



#' Check connectivity
#'
#' @param host a string with a hostname
#'
#' @return logical value
#' @keywords internal
#' @noRd
#' @importFrom curl nslookup
has_internet_2 <- function(host) {
  !is.null(nslookup(host, error = FALSE))
}


check_connectivity <- function() {
  ## check connectivity
  if (!has_internet_2("attains.epa.gov")) {
    message("No connection to attains.epa.gov available")
    return(invisible(NULL))
  }
}

