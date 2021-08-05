#' Download Domain Values
#'
#' @param domain_name (character)
#' @param context (character)
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied tibble. \code{FALSE} the function returns the raw JSON string.
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return tibble
#' @export
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
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

  ## check that arguments are character
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_character,
         x = list(domain_name, context),
         .var.name = c("domain_name", "context"),
         MoreArgs = list(null.ok = TRUE,
                         add = coll))
  checkmate::reportAssertions(coll)

  ## check logical
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_logical,
         x = list(tidy),
         .var.name = c("tidy"),
         MoreArgs = list(null.ok = FALSE,
                         add = coll))
  checkmate::reportAssertions(coll)


  # Check that domain_name is specified if context is used
  if(is.null(domain_name)) {
    if(!is.null(context)) stop("If the context argument is used, the domain_name argument must also be used")
  }

  args <- list(domainName = domain_name,
               context = context)
  args <- list.filter(args, !is.null(.data))

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
  if(!isTRUE(tidy)) {
    return(content)
    } else {
      ## parse the returned json
      content <- jsonlite::fromJSON(content, simplifyVector = FALSE)
      content <- content %>%
        enframe() %>%
        rename(id = .data$name) %>%
        unnest_wider(.data$value) %>%
        select(-.data$id) %>%
        clean_names()
      return(content)
      }
}


