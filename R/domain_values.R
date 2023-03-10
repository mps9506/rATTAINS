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
#'   reduce uneccessary calls to the server.
#' @export
#' @import tibblify
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
#' @importFrom fs path
#' @importFrom janitor clean_names
#' @examples
#'
#'
#' \dontrun{
#'
#' ## return a tibble with all domain names
#' domain_values()
#'
#' ## return allowable parameter values for a given domain name and context
#' domain_values(domain_name="UseName",context="TCEQMAIN")
#'
#' ## return the query as a JSON string instead
#' domain_values(domain_name="UseName",context="TCEQMAIN", tidy= FALSE)
#' }
domain_values <- function(domain_name = NULL,
                          context = NULL,
                          tidy = TRUE,
                          ...) {

  ## check connectivity
  check_connectivity()

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
  path = "attains-public/api/domains"

  ## download without caching
  content <- xGET(path,
                  args,
                  file = NULL,
                  ...)

  if(is.null(content)) return(content)

  if(!isTRUE(tidy)) {
    return(content)
    } else {

      ## parse json
      json_list <- jsonlite::fromJSON(content,
                                      simplifyVector = FALSE,
                                      simplifyDataFrame = FALSE,
                                      flatten = FALSE)

      ## create tibblify specification
      spec <- tspec_df(
        tib_chr("domain"),
        tib_chr("name"),
        tib_chr("code"),
        tib_chr("context", required = FALSE),
        tib_chr("context2", required = FALSE),
      )

      ## nested list -> rectangle
      content <- tibblify(json_list, spec = spec, unspecified = "drop")

      content <- clean_names(content)

      return(content)
      }
}


