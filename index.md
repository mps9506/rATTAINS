# rATTAINS

rATTAINS provides functions for downloading tidy data from the United
States (U.S.) Environmental Protection Agency (EPA)
[ATTAINS](https://www.epa.gov/waterdata/attains) webservice. ATTAINS is
the online system used to track and report Clean Water Act assessments
and Total Maximum Daily Loads (TMDLs) in U.S. surface waters. rATTAINS
facilitates access to the [public information
webservice](https://www.epa.gov/waterdata/get-data-access-public-attains-data)
made available through the EPA.

rATTAINS is on CRAN:

``` R
install.packages('rATTAINS')
```

Or install the development version from r-universe:

``` R
install.packages('rATTAINS', repos = 'https://mps9506.r-universe.dev')
```

## API Key

As of May 2026 ATTAINS utilizes free API keys issues from Data.gov. Keys
can be obtained from: <https://api.data.gov/signup/>

To utilize your API key with rATTAINS, add the following to your
.Renviron file:

`RATTAINS_TOKEN="DEMO_TOKEN"`

replacing `DEMO_TOKEN` with your actual key, and restarting your R
session. An easy way to edit this file is `usethis::edit_r_environ()`.

## Functions and webservices

There are eight user available functions that correspond with the first
eight web services detailed by
[EPA](https://www.epa.gov/waterdata/how-access-and-use-attains-web-services).
All arguments are case sensitive. By default the functions attempt to
provide flattened “tidy” data as a single or multiple dataframes. By
using the `tidy = FALSE` argument in the function below, the raw JSON
will be read into the session for the user to parse if desired. This can
be useful since some webservices provide different results based on the
query and the tidying process used in rATTAINS might make poor
assumptions in the data flattening process. If the function returns
unexpected results, try parsing the raw JSON string.

- [`state_summary()`](https://mps9506.github.io/rATTAINS/reference/state_summary.md)
  provides summary information for assessed uses for organizations and
  by integrated reporting cycle.

- `huc_12_summary()` provides summary information about impairments,
  actions, and documents for the specified 12-digit HUC (watershed).

- [`actions()`](https://mps9506.github.io/rATTAINS/reference/actions.md)
  provides a summary of information for particular finalized actions
  (TMDLs and related).

- [`assessments()`](https://mps9506.github.io/rATTAINS/reference/assessments.md)
  provides summary data about the specified assessment decisions by
  waterbody.

- [`plans()`](https://mps9506.github.io/rATTAINS/reference/plans.md)
  returns a summary of the plans (TMDLs and related) within a specified
  HUC.

- [`domain_values()`](https://mps9506.github.io/rATTAINS/reference/domain_values.md)
  returns allowed values in ATTAINS. By default (no arguments) the
  function returns a list of allowed `domain_names`.

- [`assessment_units()`](https://mps9506.github.io/rATTAINS/reference/assessment_units.md)
  returns a summary of information about the specified assessment units.

- [`surveys()`](https://mps9506.github.io/rATTAINS/reference/surveys.md)
  returns results from state statistical survey results in ATTAINS.

# Examples:

Get a summary about assessed uses from the Texas Commission on
Environmental Quality:

``` R
library(rATTAINS)
state_summary(
  organization_id = "TCEQMAIN",
  reporting_cycle = "2020",
  .unnest = FALSE
)
#> $items
#> # A tibble: 31 × 18
#>    organizationIdentifier organizationName organizationTypeText reportingCycle
#>    <chr>                  <chr>            <chr>                <chr>         
#>  1 TCEQMAIN               Texas            State                2020          
#>  2 TCEQMAIN               Texas            State                2020          
#>  3 TCEQMAIN               Texas            State                2020          
#>  4 TCEQMAIN               Texas            State                2020          
#>  5 TCEQMAIN               Texas            State                2020          
#>  6 TCEQMAIN               Texas            State                2020          
#>  7 TCEQMAIN               Texas            State                2020          
#>  8 TCEQMAIN               Texas            State                2020          
#>  9 TCEQMAIN               Texas            State                2020          
#> 10 TCEQMAIN               Texas            State                2020          
#> # ℹ 21 more rows
#> # ℹ 14 more variables: cycleStatus <chr>, combinedCycles <list>,
#> #   waterTypeCode <chr>, unitsCode <chr>, useName <chr>,
#> #   `Fully Supporting` <dbl>, `Fully Supporting-count` <int>,
#> #   `Insufficient Information` <dbl>, `Insufficient Information-count` <int>,
#> #   `Not Assessed` <dbl>, `Not Assessed-count` <int>, `Not Supporting` <dbl>,
#> #   `Not Supporting-count` <int>, parameters <list>
```

Get a summary about assessed uses, parameters and plans in a HUC12:

``` R
df <- huc12_summary(huc = "020700100204", .unnest = FALSE)

tidyr::unnest(df, items) |>
  tidyr::unnest(summaryByUseGroup)
#> # A tibble: 4 × 24
#>   huc12        assessmentUnitCount totalCatchmentAreaSqMi totalHucAreaSqMi
#>   <chr>                      <int>                  <dbl> <lgl>           
#> 1 020700100204                  18                   46.1 NA              
#> 2 020700100204                  18                   46.1 NA              
#> 3 020700100204                  18                   46.1 NA              
#> 4 020700100204                  18                   46.1 NA              
#> # ℹ 20 more variables: assessedCatchmentAreaSqMi <dbl>,
#> #   assessedCatchmentAreaPercent <dbl>, assessedGoodCatchmentAreaSqMi <int>,
#> #   assessedGoodCatchmentAreaPercent <int>,
#> #   assessedUnknownCatchmentAreaSqMi <int>,
#> #   assessedUnknownCatchmentAreaPercent <int>,
#> #   containImpairedWatersCatchmentAreaSqMi <dbl>,
#> #   containImpairedWatersCatchmentAreaPercent <dbl>, …

tidyr::unnest(df, items) |>
  tidyr::unnest(summaryByParameterImpairments, names_repair = "minimal")
#> # A tibble: 16 × 26
#>    huc12        assessmentUnitCount totalCatchmentAreaSqMi totalHucAreaSqMi
#>    <chr>                      <int>                  <dbl> <lgl>           
#>  1 020700100204                  18                   46.1 NA              
#>  2 020700100204                  18                   46.1 NA              
#>  3 020700100204                  18                   46.1 NA              
#>  4 020700100204                  18                   46.1 NA              
#>  5 020700100204                  18                   46.1 NA              
#>  6 020700100204                  18                   46.1 NA              
#>  7 020700100204                  18                   46.1 NA              
#>  8 020700100204                  18                   46.1 NA              
#>  9 020700100204                  18                   46.1 NA              
#> 10 020700100204                  18                   46.1 NA              
#> 11 020700100204                  18                   46.1 NA              
#> 12 020700100204                  18                   46.1 NA              
#> 13 020700100204                  18                   46.1 NA              
#> 14 020700100204                  18                   46.1 NA              
#> 15 020700100204                  18                   46.1 NA              
#> 16 020700100204                  18                   46.1 NA              
#> # ℹ 22 more variables: assessedCatchmentAreaSqMi <dbl>,
#> #   assessedCatchmentAreaPercent <dbl>, assessedGoodCatchmentAreaSqMi <int>,
#> #   assessedGoodCatchmentAreaPercent <int>,
#> #   assessedUnknownCatchmentAreaSqMi <int>,
#> #   assessedUnknownCatchmentAreaPercent <int>,
#> #   containImpairedWatersCatchmentAreaSqMi <dbl>,
#> #   containImpairedWatersCatchmentAreaPercent <dbl>, …

tidyr::unnest(df, items) |>
  tidyr::unnest(summaryRestorationPlans, names_repair = "minimal")
#> # A tibble: 1 × 26
#>   huc12        assessmentUnitCount totalCatchmentAreaSqMi totalHucAreaSqMi
#>   <chr>                      <int>                  <dbl> <lgl>           
#> 1 020700100204                  18                   46.1 NA              
#> # ℹ 22 more variables: assessedCatchmentAreaSqMi <dbl>,
#> #   assessedCatchmentAreaPercent <dbl>, assessedGoodCatchmentAreaSqMi <int>,
#> #   assessedGoodCatchmentAreaPercent <int>,
#> #   assessedUnknownCatchmentAreaSqMi <int>,
#> #   assessedUnknownCatchmentAreaPercent <int>,
#> #   containImpairedWatersCatchmentAreaSqMi <dbl>,
#> #   containImpairedWatersCatchmentAreaPercent <dbl>, …
```

Find statistical surveys completed by an organization:

``` R
surveys(organization_id = "SDDENR", .unnest = TRUE)
#> Unable to further unnest data, check for nested dataframes.
#> $count
#> # A tibble: 1 × 1
#>   count
#>   <int>
#> 1     5
#> 
#> $items
#> # A tibble: 25 × 15
#>    organizationIdentifier organizationName organizationTypeText surveyStatusCode
#>    <chr>                  <chr>            <chr>                <chr>           
#>  1 SDDENR                 South Dakota     State                Final           
#>  2 SDDENR                 South Dakota     State                Final           
#>  3 SDDENR                 South Dakota     State                Final           
#>  4 SDDENR                 South Dakota     State                Final           
#>  5 SDDENR                 South Dakota     State                Final           
#>  6 SDDENR                 South Dakota     State                Final           
#>  7 SDDENR                 South Dakota     State                Final           
#>  8 SDDENR                 South Dakota     State                Final           
#>  9 SDDENR                 South Dakota     State                Final           
#> 10 SDDENR                 South Dakota     State                Final           
#> # ℹ 15 more rows
#> # ℹ 11 more variables: year <int>, surveyCommentText <lgl>, documents <list>,
#> #   waterTypeGroupCode <chr>, subPopulationCode <chr>, unitCode <chr>,
#> #   size <int>, siteNumber <int>, surveyWaterGroupCommentText <chr>,
#> #   surveyWaterGroupUseParameters <list>, histories <list>
```

## Citation

If you use this package in a publication, please cite as:

``` R
citation("rATTAINS")
#> To cite rATTAINS in publications use:
#> 
#>   Schramm, Michael (2021).  rATTAINS: Access EPA 'ATTAINS' Data.  R
#>   package version 1.0.1 doi:10.5281/zenodo.5469911
#>   https://CRAN.R-project.org/package=rATTAINS
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {{rATTAINS}: Access EPA 'ATTAINS' Data},
#>     author = {Michael Schramm},
#>     year = {2025},
#>     url = {https://CRAN.R-project.org/package=rATTAINS},
#>     doi = {10.5281/zenodo.5469911},
#>     note = {R package version 1.0.1},
#>   }
```
