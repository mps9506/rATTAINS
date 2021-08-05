
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
xGET <- function(path, args = list(), file, ...) {
  url <- "https://attains.epa.gov"
  cli <- crul::HttpClient$new(url,
                              opts = list(...))
  res <- cli$get(path = path,
                 disk = file,
                 query = args)

  errs(res)

  content <- res$parse("UTF-8")
  # file.create(file)
  #cat(content, file = file)

  #attr(content, 'url') <- res$url


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
  x <- paste(x, name)
  return(x)
}




#' Loop Assertion
#'
#' @param fun function
#' @param formula formula
#' @param ... additional args passed to function (assert_*)
#' @param fixed additional args
#'
#' @return error if assertion is not met
#' @keywords internal
#' @noRd
aapply = function(fun, formula, ..., fixed = list()) {
  fun = match.fun(fun)
  terms = terms(formula)
  vnames = attr(terms, "term.labels")
  ee = attr(terms, ".Environment")

  dots = list(...)
  dots$.var.name = vnames
  dots$x = unname(mget(vnames, envir = ee))
  .mapply(fun, dots, MoreArgs = fixed)

  invisible(NULL)
}
