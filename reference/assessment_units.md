# Download Assessment Unit Summary

Provides basic information about the requested assessment units.

## Usage

``` r
assessment_units(
  assessment_unit_identifer = NULL,
  state_code = NULL,
  organization_id = NULL,
  epa_region = NULL,
  huc = NULL,
  county = NULL,
  assessment_unit_name = NULL,
  last_change_later_than_date = NULL,
  last_change_earlier_than_date = NULL,
  status_indicator = NULL,
  return_count_only = NULL,
  tidy = TRUE,
  .unnest = TRUE,
  ...
)
```

## Arguments

- assessment_unit_identifer:

  (character) Filters returned assessment units to one or more specific
  assessment units. Multiple values can be provided. optional

- state_code:

  (character) Filters returned assessment units to only those having a
  state code matches one in the provided list of states. Multiple values
  can be provided. optional

- organization_id:

  (character) Filters returned assessment units to only those having a
  mathcing organization ID. Multiple values can be provided. optional

- epa_region:

  (character) Filters returned assessment units to only matching EPA
  regions. Multiple values can be provided. optional

- huc:

  (character) Filters returned assessment units to only those which have
  a location type of HUC and the location value matches the provided
  HUC. Multiple values can be provided. optional

- county:

  (character) Filters returned assessment units to only those which have
  a location type of county and matches the provided county. Multiple
  values can be provided. optional

- assessment_unit_name:

  (character) Filters the returned assessment units to matching the
  provided value.

- last_change_later_than_date:

  (character) Filters returned assessment units to those only changed
  after the provided date. Must be a character with format:
  `"yyyy-mm-dd"`. optional

- last_change_earlier_than_date:

  (character) Filters returned assessment units to those only changed
  before the provided date. Must be a character with format:
  `"yyyy-mm-dd"`. optional

- status_indicator:

  (character) Filter the returned assessment units to those with
  specified status. "A" for active, "R" for retired. optional

- return_count_only:

  **\[deprecated\]** `return_count_only = Y` is no longer supported.

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

When `tidy = TRUE` a tibble with many variables, some nested, is
returned. When `tidy=FALSE` a raw JSON string is returned.

## Details

One or more of the following arguments must be included:
`assessment_unit_identfier`, `state_code` or `organization_id`. Multiple
values are allowed for indicated arguments and should be included as a
comma separated values in the string (eg.
`organization_id="TCEQMAIN,DCOEE"`).

## Note

See
[domain_values](https://mps9506.github.io/rATTAINS/reference/domain_values.md)
to search values that can be queried.

## Examples

``` r
if (FALSE) { # \dontrun{

## Retrieve data about a single assessment unit
assessment_units(assessment_unit_identifer = "AL03150201-0107-200")

## Retrieve data as a JSON instead
assessment_units(assessment_unit_identifer = "AL03150201-0107-200", tidy = FALSE)
} # }
```
