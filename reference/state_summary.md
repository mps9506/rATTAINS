# Download State Summaries

Provides summary information for assessed uses for an organization
(State, Territory or Tribe) and Integrated Reporting Cycle. The
Organization ID for the state, territory or tribe is required. If a
Reporting Cycle isn't provided, the service will return the most recent
cycle. If a reporting Cycle is provided, the service will return a
summary for the requested cycle.

## Usage

``` r
state_summary(
  organization_id = NULL,
  reporting_cycle = NULL,
  tidy = TRUE,
  .unnest = TRUE,
  ...
)
```

## Arguments

- organization_id:

  (character) Restricts results to the specified organization. required

- reporting_cycle:

  (character) Filters the returned results to the specified 4 digit
  reporting cycle year. Typically even numbered years. Will return
  reporting data for all years prior to and including the reporting
  cycle by reporting cycle. optional

- tidy:

  (logical) `TRUE` (default) the function returns a tidied tibble.
  `FALSE` the function returns the raw JSON string.

- .unnest:

  (logical) `TRUE` (default) the function attempts to unnest data to
  longest format possible. This defaults to `TRUE` for backwards
  compatibility but it is suggested to use `FALSE`.

- ...:

  list of curl options passed to
  [`crul::HttpClient()`](https://docs.ropensci.org/crul/reference/HttpClient.html)

## Value

If `tidy = FALSE` the raw JSON string is returned, else the JSON data is
parsed and returned as a list of tibbles.

## Note

See
[domain_values](https://mps9506.github.io/rATTAINS/reference/domain_values.md)
to search values that can be queried.

## Examples

``` r
if (FALSE) { # \dontrun{
## Get a list of tibbles summarizing assessed uses
state_summary(organization_id = "TDECWR", reporting_cycle = "2016")

## Returns the query as a JSON string instead
state_summary(organization_id = "TDECWR", reporting_cycle = "2016", tidy = FALSE)
} # }
```
