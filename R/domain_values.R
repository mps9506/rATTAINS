#' Download Domain Values
#' @description Provides information on allowed parameter values in ATTAINS.
#' @param domain_name (character) Specified the domain name to obtain valid
#'   parameter values for. Defaults to \code{NULL} which will a tibble with all
#'   the domain names. To return the allowable parameter values for a given
#'   domain, the domain should be specified here. optional
#' @param context (character) When specified, the service will return
#'   domain_name values  alongside the context. optional.
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied
#'   tibble. \code{FALSE} the function returns the raw JSON string.
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return If \code{tidy = FALSE} the raw JSON string is returned, else the JSON
#'   data is parsed and returned as a tibble.
#' @note  Data downloaded from the EPA webservice is automatically cached to
#'   reduce uneccessary calls to the server. To managed cached files see
#'   [rATTAINS_caching]
#' @export
#' @import tidyjson
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
#' @importFrom dplyr select rename
#' @importFrom fs path
#' @importFrom janitor clean_names
#' @importFrom rlang .data
#' @importFrom tibble as_tibble
domain_values <- function(domain_name = NULL,
                          context = NULL,
                          tidy = TRUE,
                          ...) {

  ## check that arguments are character
  coll <- makeAssertCollection()
  mapply(FUN = assert_character,
         x = list(domain_name, context),
         .var.name = c("domain_name", "context"),
         MoreArgs = list(null.ok = TRUE,
                         add = coll))
  reportAssertions(coll)

  ## check logical
  coll <- makeAssertCollection()
  mapply(FUN = assert_logical,
         x = list(tidy),
         .var.name = c("tidy"),
         MoreArgs = list(null.ok = FALSE,
                         add = coll))
  reportAssertions(coll)


  # Check that domain_name is specified if context is used
  if(is.null(domain_name)) {
    if(!is.null(context)) stop("If the context argument is used, the domain_name argument must also be used")
  }

  args <- list(domainName = domain_name,
               context = context)
  args <- list.filter(args, !is.null(.data))

  ##setup file cache
  path = "attains-public/api/domains"
  dv_cache$mkdir()

  ## check if current results have been cached
  file_cache_name <- file_key(arg_list = args,
                              name = "domains.json")
  file_path_name <- path(dv_cache$cache_path_get(),
                         file_cache_name)

  if(file.exists(file_path_name)) {
    message(paste0("reading cached file from: ", file_path_name))
    content <- readLines(file_path_name, warn = FALSE)
  } else {## download data
    content <- xGET(path,
                    args,
                    file = file_path_name,
                    ...)
    }
  if(!isTRUE(tidy)) {
    return(content)
    } else {
      ## parse the returned json
      content <- content %>%
        gather_array() %>%
        spread_values(
          domain = jstring("domain"),
          name = jstring("name"),
          code = jstring("code"),
          context = jstring("context")
        ) %>%
        select(-c(.data$document.id, .data$array.index)) %>%
        as_tibble() %>%
        clean_names() -> content_domain
      return(content)
      }
}


