#' Download Domain Values
#'
#' @param domain_name (character)
#' @param context (character)
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


  path = "attains-public/api/domains"

  content <- xGET(path, args, ...)

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
