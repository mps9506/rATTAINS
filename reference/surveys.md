# Download State Survey Results

Downloads data about state statistical (probability) survey results.

## Usage

``` r
surveys(
  organization_id = NULL,
  survey_year = NULL,
  tidy = TRUE,
  .unnest = TRUE,
  ...
)
```

## Arguments

- organization_id:

  (character) Filters the list to only those “belonging to” one of the
  specified organizations. Multiple values may be specified. required

- survey_year:

  (character) Filters the list to the year the survey was performed.
  optional.

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

## Details

Arguments that allow multiple values should be entered as a comma
separated string with no spaces (`organization_id = "DOEE,21AWIC"`).

## Note

See
[domain_values](https://mps9506.github.io/rATTAINS/reference/domain_values.md)
to search values that can be queried.

## Examples

``` r
if (FALSE) { # \dontrun{

## return surveys by organization
surveys(organization_id="SDDENR")

## return as a JSON string instead of a list of tibbles
surveys(organization_id="SDDENR", tidy = FALSE)
} # }
```
