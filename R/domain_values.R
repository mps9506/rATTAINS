#' Download Domain Values
#'
#' @param domain_name (character)
#' @param context (character)
#'
#' @return
#' @export
domain_values <- function(domain_name = NULL,
                          context = NULL) {

  # Check that organization_id is character
  if(is.null(domain_name)) {
    if(!is.null(context)) stop("If the context argument is used, the domain_name argument must also be used")
    args = list()
  } else {
    if(!is.character(domain_name)){
      stop("domain_name must be character")
    } else {
      if(is.null(context)) {
        args = list(domain_name = domain_name)
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

  return(content)

}
