
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rATTAINS

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/rATTAINS)](https://cran.r-project.org/package=rATTAINS)
[![rATTAINS status
badge](https://mps9506.r-universe.dev/badges/rATTAINS)](https://mps9506.r-universe.dev)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check](https://github.com/mps9506/rATTAINS/workflows/R-CMD-check/badge.svg)](https://github.com/mps9506/rATTAINS/actions)
[![codecov](https://codecov.io/gh/mps9506/rATTAINS/branch/main/graph/badge.svg?token=J45QIKWA8E)](https://app.codecov.io/gh/mps9506/rATTAINS)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5469911.svg)](https://doi.org/10.5281/zenodo.5469911)

<!-- badges: end -->

rATTAINS provides functions for downloading tidy data from the United
States (U.S.) Environmental Protection Agency (EPA)
[ATTAINS](https://www.epa.gov/waterdata/attains) webservice. ATTAINS is
the online system used to track and report Clean Water Act assessments
and Total Maximum Daily Loads (TMDLs) in U.S. surface waters. rATTAINS
facilitates access to the [public information
webservice](https://www.epa.gov/waterdata/get-data-access-public-attains-data)
made available through the EPA.

rATTAINS is on CRAN:

``` r
install.packages('rATTAINS')
```

Or install the development version from r-universe:

``` r
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

- `state_summary()` provides summary information for assessed uses for
  organizations and by integrated reporting cycle.

- `huc_12_summary()` provides summary information about impairments,
  actions, and documents for the specified 12-digit HUC (watershed).

- `actions()` provides a summary of information for particular finalized
  actions (TMDLs and related).

- `assessments()` provides summary data about the specified assessment
  decisions by waterbody.

- `plans()` returns a summary of the plans (TMDLs and related) within a
  specified HUC.

- `domain_values()` returns allowed values in ATTAINS. By default (no
  arguments) the function returns a list of allowed `domain_names`.

- `assessment_units()` returns a summary of information about the
  specified assessment units.

- `surveys()` returns results from state statistical survey results in
  ATTAINS.

# Examples:

Get a summary about assessed uses from the Texas Commission on
Environmental Quality:

``` r
library(rATTAINS)
state_summary(
  organization_id = "TCEQMAIN",
  reporting_cycle = "2020",
  .unnest = FALSE
)
#> $items
#> # A tibble: 31 × 18
#>    organizationIdentifier organizationName organizationTypeText reportingCycle cycleStatus      combinedCycles waterTypeCode unitsCode  useName `Fully Supporting`
#>    <chr>                  <chr>            <chr>                <chr>          <chr>            <list>         <chr>         <chr>      <chr>                <dbl>
#>  1 TCEQMAIN               Texas            State                2020           EPA Final Action <list [0]>     ESTUARY       Square Mi… Aquati…              1861.
#>  2 TCEQMAIN               Texas            State                2020           EPA Final Action <list [0]>     ESTUARY       Square Mi… Recrea…              2255.
#>  3 TCEQMAIN               Texas            State                2020           EPA Final Action <list [0]>     ESTUARY       Square Mi… Oyster…              1521.
#>  4 TCEQMAIN               Texas            State                2020           EPA Final Action <list [0]>     ESTUARY       Square Mi… Genera…              2514.
#>  5 TCEQMAIN               Texas            State                2020           EPA Final Action <list [0]>     ESTUARY       Square Mi… Fish C…               270.
#>  6 TCEQMAIN               Texas            State                2020           EPA Final Action <list [0]>     RESERVOIR     Acres      DOMEST…           1307186.
#>  7 TCEQMAIN               Texas            State                2020           EPA Final Action <list [0]>     RESERVOIR     Acres      Aquati…           1081213.
#>  8 TCEQMAIN               Texas            State                2020           EPA Final Action <list [0]>     RESERVOIR     Acres      Fish C…            159491.
#>  9 TCEQMAIN               Texas            State                2020           EPA Final Action <list [0]>     RESERVOIR     Acres      Genera…           1141350.
#> 10 TCEQMAIN               Texas            State                2020           EPA Final Action <list [0]>     RESERVOIR     Acres      Recrea…            842009.
#> # ℹ 21 more rows
#> # ℹ 8 more variables: `Fully Supporting-count` <int>, `Insufficient Information` <dbl>, `Insufficient Information-count` <int>, `Not Assessed` <dbl>,
#> #   `Not Assessed-count` <int>, `Not Supporting` <dbl>, `Not Supporting-count` <int>, parameters <list>
```

Get a summary about assessed uses, parameters and plans in a HUC12:

``` r
df <- huc12_summary(huc = "020700100204", .unnest = FALSE)

tidyr::unnest(df, items) |>
  tidyr::unnest(summaryByUseGroup)
#> # A tibble: 4 × 24
#>   huc12    assessmentUnitCount totalCatchmentAreaSqMi totalHucAreaSqMi assessedCatchmentAre…¹ assessedCatchmentAre…² assessedGoodCatchmen…³ assessedGoodCatchmen…⁴
#>   <chr>                  <int>                  <dbl> <lgl>                             <dbl>                  <dbl>                  <int>                  <int>
#> 1 0207001…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#> 2 0207001…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#> 3 0207001…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#> 4 0207001…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#> # ℹ abbreviated names: ¹​assessedCatchmentAreaSqMi, ²​assessedCatchmentAreaPercent, ³​assessedGoodCatchmentAreaSqMi, ⁴​assessedGoodCatchmentAreaPercent
#> # ℹ 16 more variables: assessedUnknownCatchmentAreaSqMi <int>, assessedUnknownCatchmentAreaPercent <int>, containImpairedWatersCatchmentAreaSqMi <dbl>,
#> #   containImpairedWatersCatchmentAreaPercent <dbl>, containRestorationCatchmentAreaSqMi <dbl>, containRestorationCatchmentAreaPercent <dbl>,
#> #   assessmentUnits <list>, summaryByIRCategory <list>, summaryByOverallStatus <list>, useGroupName <chr>, useAttainmentSummary <list>, summaryByUse <list>,
#> #   summaryByParameterImpairments <list>, summaryRestorationPlans <list>, summaryVisionRestorationPlans <list>, count <int>

tidyr::unnest(df, items) |>
  tidyr::unnest(summaryByParameterImpairments, names_repair = "minimal")
#> # A tibble: 16 × 26
#>    huc12   assessmentUnitCount totalCatchmentAreaSqMi totalHucAreaSqMi assessedCatchmentAre…¹ assessedCatchmentAre…² assessedGoodCatchmen…³ assessedGoodCatchmen…⁴
#>    <chr>                 <int>                  <dbl> <lgl>                             <dbl>                  <dbl>                  <int>                  <int>
#>  1 020700…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#>  2 020700…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#>  3 020700…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#>  4 020700…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#>  5 020700…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#>  6 020700…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#>  7 020700…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#>  8 020700…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#>  9 020700…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#> 10 020700…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#> 11 020700…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#> 12 020700…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#> 13 020700…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#> 14 020700…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#> 15 020700…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#> 16 020700…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#> # ℹ abbreviated names: ¹​assessedCatchmentAreaSqMi, ²​assessedCatchmentAreaPercent, ³​assessedGoodCatchmentAreaSqMi, ⁴​assessedGoodCatchmentAreaPercent
#> # ℹ 18 more variables: assessedUnknownCatchmentAreaSqMi <int>, assessedUnknownCatchmentAreaPercent <int>, containImpairedWatersCatchmentAreaSqMi <dbl>,
#> #   containImpairedWatersCatchmentAreaPercent <dbl>, containRestorationCatchmentAreaSqMi <dbl>, containRestorationCatchmentAreaPercent <dbl>,
#> #   assessmentUnits <list>, summaryByIRCategory <list>, summaryByOverallStatus <list>, summaryByUseGroup <list>, summaryByUse <list>, parameterGroupName <chr>,
#> #   catchmentSizeSqMi <dbl>, catchmentSizePercent <dbl>, assessmentUnitCount <int>, summaryRestorationPlans <list>, summaryVisionRestorationPlans <list>,
#> #   count <int>

tidyr::unnest(df, items) |>
  tidyr::unnest(summaryRestorationPlans, names_repair = "minimal")
#> # A tibble: 1 × 26
#>   huc12    assessmentUnitCount totalCatchmentAreaSqMi totalHucAreaSqMi assessedCatchmentAre…¹ assessedCatchmentAre…² assessedGoodCatchmen…³ assessedGoodCatchmen…⁴
#>   <chr>                  <int>                  <dbl> <lgl>                             <dbl>                  <dbl>                  <int>                  <int>
#> 1 0207001…                  18                   46.1 NA                                 35.2                   76.4                      0                      0
#> # ℹ abbreviated names: ¹​assessedCatchmentAreaSqMi, ²​assessedCatchmentAreaPercent, ³​assessedGoodCatchmentAreaSqMi, ⁴​assessedGoodCatchmentAreaPercent
#> # ℹ 18 more variables: assessedUnknownCatchmentAreaSqMi <int>, assessedUnknownCatchmentAreaPercent <int>, containImpairedWatersCatchmentAreaSqMi <dbl>,
#> #   containImpairedWatersCatchmentAreaPercent <dbl>, containRestorationCatchmentAreaSqMi <dbl>, containRestorationCatchmentAreaPercent <dbl>,
#> #   assessmentUnits <list>, summaryByIRCategory <list>, summaryByOverallStatus <list>, summaryByUseGroup <list>, summaryByUse <list>,
#> #   summaryByParameterImpairments <list>, summaryTypeName <chr>, catchmentSizeSqMi <dbl>, catchmentSizePercent <dbl>, assessmentUnitCount <int>,
#> #   summaryVisionRestorationPlans <list>, count <int>
```

Find statistical surveys completed by an organization:

``` r
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
#>    organizationIdentifier organizationName organizationTypeText surveyStatusCode  year surveyCommentText documents waterTypeGroupCode  subPopulationCode unitCode
#>    <chr>                  <chr>            <chr>                <chr>            <int> <lgl>             <list>    <chr>               <chr>             <chr>   
#>  1 SDDENR                 South Dakota     State                Final             2018 NA                <NULL>    LAKE/RESERVOIR/POND Statewide         Acres   
#>  2 SDDENR                 South Dakota     State                Final             2018 NA                <NULL>    LAKE/RESERVOIR/POND Statewide         Acres   
#>  3 SDDENR                 South Dakota     State                Final             2018 NA                <NULL>    LAKE/RESERVOIR/POND Statewide         Acres   
#>  4 SDDENR                 South Dakota     State                Final             2018 NA                <NULL>    LAKE/RESERVOIR/POND Statewide         Acres   
#>  5 SDDENR                 South Dakota     State                Final             2018 NA                <NULL>    LAKE/RESERVOIR/POND Statewide         Acres   
#>  6 SDDENR                 South Dakota     State                Final             2016 NA                <NULL>    LAKE/RESERVOIR/POND Statewide         Acres   
#>  7 SDDENR                 South Dakota     State                Final             2016 NA                <NULL>    LAKE/RESERVOIR/POND Statewide         Acres   
#>  8 SDDENR                 South Dakota     State                Final             2016 NA                <NULL>    LAKE/RESERVOIR/POND Statewide         Acres   
#>  9 SDDENR                 South Dakota     State                Final             2016 NA                <NULL>    LAKE/RESERVOIR/POND Statewide         Acres   
#> 10 SDDENR                 South Dakota     State                Final             2016 NA                <NULL>    LAKE/RESERVOIR/POND Statewide         Acres   
#> # ℹ 15 more rows
#> # ℹ 5 more variables: size <int>, siteNumber <int>, surveyWaterGroupCommentText <chr>, surveyWaterGroupUseParameters <list>, histories <list>
```

## Citation

If you use this package in a publication, please cite as:

``` r
citation("rATTAINS")
#> To cite rATTAINS in publications use:
#> 
#>   Schramm, Michael (2021).  rATTAINS: Access EPA 'ATTAINS' Data.  R package version 1.0.1 doi:10.5281/zenodo.5469911
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
