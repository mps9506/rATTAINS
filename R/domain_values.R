#' Download Domain Values
#'
#' @param domain_name (character)
#' @param context (character)
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied tibble. \code{FALSE} the function returns the raw JSON string.
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return tibble
#' @export
#' @importFrom dplyr select rename
#' @importFrom janitor clean_names
#' @importFrom jsonlite fromJSON
#' @importFrom rlang .data
#' @importFrom tibble enframe
#' @importFrom tidyr unnest_longer unnest_wider
domain_values <- function(domain_name = NULL,
                          context = NULL,
                          tidy = TRUE,
                          ...) {

  # Check that organization_id is character
  if(is.null(domain_name)) {
    if(!is.null(context)) stop("If the context argument is used, the domain_name argument must also be used")
    args = list()
  } else {
    if(!is.character(domain_name)){
      stop("domain_name must be character")
    } else {
      if(is.null(context)) {
        args = list(domainName = domain_name)
      } else {
        if(!is.character(context)) {
          stop("context must be character")
        } else {
          args = list(domainName = domain_name,
                      context = context)
        }
      }
    }
  }

  ##setup file cache
  dv_cache <- hoardr::hoard()
  path = "attains-public/api/domains"
  print(args)
  file <- file_key(path = path, arg_list = args)
  dv_cache$cache_path_set(path = file)
  dv_cache$mkdir()

  ## check if current results have been cached
  file_name <- file.path(dv_cache$cache_path_get(),
                         "domains.json")

  if(file.exists(file_name)) {
    message(paste0("reading cached file from: ", file_name))
    content <- readLines(file_name, warn = FALSE)
  } else {## download data
    content <- xGET(path,
                    args,
                    file = file_name,
                    ...)
    }
    ## parse the returned json
    content <- jsonlite::fromJSON(content, simplifyVector = FALSE)
    if(!isTRUE(tidy)) {
      return(content)
    } else {
      content <- content %>%
        enframe() %>%
        rename(id = .data$name) %>%
        unnest_wider(.data$value) %>%
        select(-.data$id) %>%
        clean_names()
      return(content)
      }
}


