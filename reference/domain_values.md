# Download Domain Values

Provides information on allowed parameter values in ATTAINS.

## Usage

``` r
domain_values(domain_name = NULL, context = NULL, tidy = TRUE, ...)
```

## Arguments

- domain_name:

  (character) Specified the domain name to obtain valid parameter values
  for. Defaults to `NULL` which will a tibble with all the domain names.
  To return the allowable parameter values for a given domain, the
  domain should be specified here. optional

- context:

  (character) When specified, the service will return domain_name values
  alongside the context. optional.

- tidy:

  (logical) `TRUE` (default) the function returns a tidied tibble.
  `FALSE` the function returns the raw JSON string.

- ...:

  list of curl options passed to
  [`crul::HttpClient()`](https://docs.ropensci.org/crul/reference/HttpClient.html)

## Value

If `tidy = FALSE` the raw JSON string is returned, else the JSON data is
parsed and returned as a tibble.

## Note

Data downloaded from the EPA webservice is automatically cached to
reduce uneccessary calls to the server.

## Examples

``` r

if (FALSE) { # \dontrun{

## return a tibble with all domain names
domain_values()

## return allowable parameter values for a given domain name and context
domain_values(domain_name="UseName",context="TCEQMAIN")

## return the query as a JSON string instead
domain_values(domain_name="UseName",context="TCEQMAIN", tidy= FALSE)
} # }
```
