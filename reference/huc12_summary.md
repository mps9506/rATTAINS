# Download HUC12 Summary

Provides summary data for a 12-digit Hydrologic Unit Code (HUC12), based
on Assessment Units in the HUC12. Watershed boundaries may cross state
boundaries, so the service may return assessment units from multiple
organizations. Returns the assessment units in the HUC12, size and
percentages of assessment units considered Good, Unknown, or Impaired.

## Usage

``` r
huc12_summary(huc, tidy = TRUE, .unnest = TRUE, ...)
```

## Arguments

- huc:

  (character) Specifies the 12-digit HUC to be summarized. required

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
parsed and returned as a list of tibbles that include a list of seven
tibbles.

## Note

See
[domain_values](https://mps9506.github.io/rATTAINS/reference/domain_values.md)
to search values that can be queried.

## Examples

``` r
if (FALSE) { # \dontrun{
## Return a list of tibbles with summary data about a single huc12
x <- huc12_summary(huc = "020700100204")

## Return as a JSON string
x <- huc12_summary(huc = "020700100204", tidy = FALSE)
} # }
```
