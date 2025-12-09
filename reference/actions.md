# Download Actions Data

Provides data about actions (TMDLs, 4B Actions, Alternative Actions,
Protection Approach Actions) that have been finalized.

## Usage

``` r
actions(
  action_id = NULL,
  assessment_unit_id = NULL,
  state_code = NULL,
  organization_id = NULL,
  summarize = FALSE,
  parameter_name = NULL,
  pollutant_name = NULL,
  action_type_code = NULL,
  agency_code = NULL,
  pollutant_source_code = NULL,
  action_status_code = NULL,
  completion_date_later_than = NULL,
  completion_date_earlier_than = NULL,
  tmdl_date_later_than = NULL,
  tmdl_date_earlier_then = NULL,
  last_change_later_than_date = NULL,
  last_change_earlier_than_date = NULL,
  return_count_only = FALSE,
  tidy = TRUE,
  .unnest = TRUE,
  ...
)
```

## Arguments

- action_id:

  (character) Specifies what action to retrieve. multiple values
  allowed. optional

- assessment_unit_id:

  (character) Filters returned actions to those associated with the
  specified assessment unit identifier, plus any statewide actions.
  multiple values allowed. optional

- state_code:

  (character) Filters returned actions to those "belonging" to the
  specified state. optional

- organization_id:

  (character) Filter returned actions to those "belonging" to specified
  organizations. multiple values allowed. optional

- summarize:

  (logical) If `TRUE` provides only a count of the assessment units for
  the action and summary of the pollutants and parameters covered by the
  action.

- parameter_name:

  (character) Filters returned actions to those associated with the
  specified parameter. multiple values allowed. optional

- pollutant_name:

  (character) Filters returned actions to those associated with the
  specified pollutant. multiple values allowed. optional

- action_type_code:

  (character) Filters returned actions to those associated with the
  specified action type code. multiple values allowed. optional

- agency_code:

  (character) Filters returned actions to those with the specified
  agency code. multiple values allowed. optional

- pollutant_source_code:

  (character) Filters returned actions to those matching the specified
  pollutant source code. multiple values allowed. optional

- action_status_code:

  (character) Filters returned actions to those matching the specified
  action status code. multiple values allowed. optional

- completion_date_later_than:

  (character) Filters returned actions to those with a completion date
  later than the value specified. Must be a character formatted as
  `"YYYY-MM-DD"`. optional

- completion_date_earlier_than:

  (character) Filters returned actions to those with a completion date
  earlier than the value specified. Must be a character formatted as
  `"YYYY-MM-DD"`. optional

- tmdl_date_later_than:

  (character) Filters returned actions to those with a TMDL date later
  than the value specified. Must be a character formatted as
  `"YYYY-MM-DD"`. optional

- tmdl_date_earlier_then:

  (character) Filters returned actions to those with a TMDL date earlier
  than the value specified. Must be a character formatted as
  `"YYYY-MM-DD"`. optional

- last_change_later_than_date:

  (character) Filters returned actions to those with a last change date
  later than the value specified. Can be used with
  `last_change_earlier_than_date` to return actions changed within a
  date range. Must be a character formatted as `"YYYY-MM-DD"`. optional

- last_change_earlier_than_date:

  (character) Filters returned actions to those with a last change date
  earlier than the value specified. Can be used with
  `last_change_later_than_date` to return actions changed within a date
  range. Must be a character formatted as `"YYYY-MM-DD"`. optional

- return_count_only:

  **\[deprecated\]** `return_count_only = TRUE` is no longer supported.

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
parsed and returned as tibbles.

## Details

One or more of the following arguments must be included: `action_id`,
`assessment_unit_id`, `state_code` or `organization_id`. Multiple values
are allowed for indicated arguments and should be included as a comma
separated values in the string (eg. `organization_id="TCEQMAIN,DCOEE"`).

## Note

See
[domain_values](https://mps9506.github.io/rATTAINS/reference/domain_values.md)
to search values that can be queried.

## Examples

``` r
if (FALSE) { # \dontrun{

## Look up an individual action
actions(action_id = "R8-ND-2018-03")
## Get the JSON instead
actions(action_id = "R8-ND-2018-03", tidy = FALSE)
} # }
```
