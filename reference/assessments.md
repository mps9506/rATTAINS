# Download Assessment Decisions

Download Assessment Decisions

## Usage

``` r
assessments(
  assessment_unit_id = NULL,
  state_code = NULL,
  organization_id = NULL,
  reporting_cycle = NULL,
  use = NULL,
  use_support = NULL,
  parameter = NULL,
  parameter_status_name = NULL,
  probable_source = NULL,
  agency_code = NULL,
  ir_category = NULL,
  state_ir_category_code = NULL,
  multicategory_search = NULL,
  last_change_later_than_date = NULL,
  last_change_earlier_than_date = NULL,
  return_count_only = FALSE,
  exclude_assessments = FALSE,
  tidy = TRUE,
  .unnest = TRUE,
  ...
)
```

## Arguments

- assessment_unit_id:

  (character) Specify the specific assessment unit assessment data to
  return. Multiple values can be provided. optional

- state_code:

  (character) Filters returned assessments to those from the specified
  state. optional

- organization_id:

  (character) Filters the returned assessments to those belonging to the
  specified organization. optional

- reporting_cycle:

  (character) Filters the returned assessments to those for the
  specified reporting cycle. The reporting cycle refers to the
  four-digit year that the reporting cycle ended. Defaults to the
  current cycle. optional

- use:

  (character) Filters the returned assessments to those with the
  specified uses. Multiple values can be provided. optional

- use_support:

  (character) Filters returned assessments to those fully supporting the
  specified uses or that are threatened. Multiple values can be
  provided. Allowable values include `"X"`= Not Assessed, `"I"`=
  Insufficient Information, `"F"`= Fully Supporting, `"N"`= Not
  Supporting, and `"T"`= Threatened. optional

- parameter:

  (character) Filters the returned assessments to those with one or more
  of the specified parameters. Multiple values can be provided. optional

- parameter_status_name:

  (character) Filters the returned assessments to those with one or more
  associated parameters meeting the provided value. Valid values are
  `"Meeting Criteria"`, `"Cause"`, `"Observed Effect"`. Multiple valuse
  can be provided. optional

- probable_source:

  (character) Filters the returned assessments to those having the
  specified probable source. Multiple values can be provided. optional

- agency_code:

  (character) Filters the returned assessments to those by the type of
  agency responsible for the assessment. Allowed values are `"E"`=EPA,
  `"S"`=State, `"T"`=Tribal. optional

- ir_category:

  (character) Filters the returned assessments to those having the
  specified IR category. Multiple values can be provided. optional

- state_ir_category_code:

  (character) Filters the returned assessments to include those having
  the provided codes.

- multicategory_search:

  (character) Specifies whether to search at multiple levels. If this
  parameter is set to “Y” then the query applies the EPA IR Category at
  the Assessment, UseAttainment, and Parameter levels; if the parameter
  is set to “N” it looks only at the Assessment level.

- last_change_later_than_date:

  (character) Filters the returned assessments to only those last
  changed after the provided date. Must be a character with format:
  `"yyyy-mm-dd"`. optional

- last_change_earlier_than_date:

  (character) Filters the returned assessments to only those last
  changed before the provided date. Must be a character with format:
  `"yyyy-mm-dd"`. optional

- return_count_only:

  **\[deprecated\]** `return_count_only = TRUE` is no longer supported.

- exclude_assessments:

  (logical) If `TRUE` returns only the documents associated with the
  Assessment cycle instead of the assessment data. Defaults is `FALSE`.

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
to search values that can be queried. In v1.0.0 rATTAINS returns a list
of tibbles (`documents`, `use_assessment`, `delisted_waters`). Prior
versions returned `documents`, `use_assessment`, and
`parameter_assessment`.

## Examples

``` r
if (FALSE) { # \dontrun{

## Return all assessment decisions with specified parameters
assessments(organization_id = "SDDENR",
probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES")

## Returns the raw JSONs instead:
assessments(organization_id = "SDDENR",
probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES", tidy = FALSE)
} # }
```
