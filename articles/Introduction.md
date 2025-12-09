# Introduction

## About

The Assessment, Total Maximum Daily Load (TMDL) Tracking and
Implementation System (ATTAINS) is the U.S. Environmental Protection
Agency (EPA) database used to track information provided by states about
water quality assessments conducted under the Clean Water Act. The
assessments are conducted every two years to evaluate if the nation’s
water bodies meet water quality standards. States are required to take
Actions (TMDLs or other efforts) on water bodies that do not meet
standards. Public information in ATTAINS is made available through
webservices and provided as JSON files. rATTAINS facilitates accessing
this data with various functions that provide raw JSON or formatted
“tidy” data for each of the ATTAINS webservice endpoints. More
information about Clean Water Act assessment and reporting is available
through the
[EPA](https://www.epa.gov/waterdata/attains-program-information). For
alternative methods of accessing the same data, see [“How’s My Waterway”
webpage](https://mywaterway.epa.gov/) for interactive data exploration
or the [ArcGIS
MapService](https://gispub.epa.gov/arcgis/rest/services/OW/ATTAINS_Assessment/MapServer)
for spatial data.

## Functions

### Summary Services

The EPA provides two summary service endpoint that provide summaries of
assessed uses by the organization identifier or by hydrologic unit code
(HUC). For example, to return a summary of assessed uses by the state of
Tennessee the following function is used:

``` r
library(rATTAINS)
x <- state_summary(organization_id = "TDECWR",
                   reporting_cycle = "2024")
x
#> $items
#> # A tibble: 20 × 18
#>    organizationIdentifier organizationName organizationTypeText reportingCycle
#>    <chr>                  <chr>            <chr>                <chr>         
#>  1 TDECWR                 Tennessee        State                2024          
#>  2 TDECWR                 Tennessee        State                2024          
#>  3 TDECWR                 Tennessee        State                2024          
#>  4 TDECWR                 Tennessee        State                2024          
#>  5 TDECWR                 Tennessee        State                2024          
#>  6 TDECWR                 Tennessee        State                2024          
#>  7 TDECWR                 Tennessee        State                2024          
#>  8 TDECWR                 Tennessee        State                2024          
#>  9 TDECWR                 Tennessee        State                2024          
#> 10 TDECWR                 Tennessee        State                2024          
#> 11 TDECWR                 Tennessee        State                2024          
#> 12 TDECWR                 Tennessee        State                2024          
#> 13 TDECWR                 Tennessee        State                2024          
#> 14 TDECWR                 Tennessee        State                2024          
#> 15 TDECWR                 Tennessee        State                2024          
#> 16 TDECWR                 Tennessee        State                2024          
#> 17 TDECWR                 Tennessee        State                2024          
#> 18 TDECWR                 Tennessee        State                2024          
#> 19 TDECWR                 Tennessee        State                2024          
#> 20 TDECWR                 Tennessee        State                2024          
#> # ℹ 14 more variables: cycleStatus <chr>, combinedCycles <list>,
#> #   waterTypeCode <chr>, unitsCode <chr>, useName <chr>,
#> #   `Fully Supporting` <dbl>, `Fully Supporting-count` <int>,
#> #   `Insufficient Information` <dbl>, `Insufficient Information-count` <int>,
#> #   `Not Assessed` <dbl>, `Not Assessed-count` <int>, `Not Supporting` <dbl>,
#> #   `Not Supporting-count` <int>, parameters <list>
```

The HUC12 service operates similarly but provides data summarized by
area, specifically HUC12 units. For example:

``` r
x <- huc12_summary("020700100204")
x
#> $hucSummary
#> # A tibble: 1 × 15
#>   huc12        assessmentUnitCount totalCatchmentAreaSqMi totalHucAreaSqMi
#>   <chr>                      <int>                  <dbl>            <dbl>
#> 1 020700100204                  18                   46.1             46.2
#> # ℹ 11 more variables: assessedCatchmentAreaSqMi <dbl>,
#> #   assessedCatchmentAreaPercent <dbl>, assessedGoodCatchmentAreaSqMi <int>,
#> #   assessedGoodCatchmentAreaPercent <int>,
#> #   assessedUnknownCatchmentAreaSqMi <int>,
#> #   assessedUnknownCatchmentAreaPercent <int>,
#> #   containImpairedWatersCatchmentAreaSqMi <dbl>,
#> #   containImpairedWatersCatchmentAreaPercent <dbl>, …
#> 
#> $assessmentUnits
#> # A tibble: 18 × 1
#>    assessmentUnitId            
#>    <chr>                       
#>  1 MD-02140205-Northwest_Branch
#>  2 MD-02140205                 
#>  3 DCTFD01R_00                 
#>  4 DCTNA01R_00                 
#>  5 DCTFS01R_00                 
#>  6 MD-ANATF                    
#>  7 DCTTX27R_00                 
#>  8 DCTFC01R_00                 
#>  9 MD-ANATF-SWSAV              
#> 10 MD-02140205-Mainstem        
#> 11 DCTWB00R_02                 
#> 12 DCANA00E_02                 
#> 13 DCTHR01R_00                 
#> 14 DCTWB00R_01                 
#> 15 DCTPB01R_00                 
#> 16 DCTDU01R_00                 
#> 17 DCANA00E_01                 
#> 18 DCAKL00L_00                 
#> 
#> $summaryByIRCategory
#> # A tibble: 2 × 4
#>   epaIRCategoryName catchmentSizeSqMi catchmentSizePercent assessmentUnitCount
#>   <chr>                         <dbl>                <dbl>               <int>
#> 1 4A                             13.2                 28.7                  11
#> 2 5                              23.0                 49.9                   7
#> 
#> $summaryByOverallStatus
#> # A tibble: 1 × 4
#>   overallStatus  catchmentSizeSqMi catchmentSizePercent assessmentUnitCount
#>   <chr>                      <dbl>                <dbl>               <int>
#> 1 Not Supporting              35.2                 76.4                  18
#> 
#> $summaryByUseGroup
#> # A tibble: 4 × 2
#>   useGroupName        useAttainmentSummary
#>   <chr>               <list>              
#> 1 ECOLOGICAL_USE      <df [2 × 4]>        
#> 2 FISHCONSUMPTION_USE <df [1 × 4]>        
#> 3 OTHER_USE           <df [1 × 4]>        
#> 4 RECREATION_USE      <df [2 × 4]>        
#> 
#> $summaryByUse
#> # A tibble: 11 × 3
#>    useName                                     useGroupName useAttainmentSummary
#>    <chr>                                       <chr>        <list>              
#>  1 Aquatic Life and Wildlife                   ECOLOGICAL_… <df [1 × 4]>        
#>  2 Fishing                                     FISHCONSUMP… <df [1 × 4]>        
#>  3 Navigation                                  OTHER_USE    <df [1 × 4]>        
#>  4 Open-Water Fish and Shellfish Subcategory   ECOLOGICAL_… <df [1 × 4]>        
#>  5 Primary Contact Recreation                  RECREATION_… <df [1 × 4]>        
#>  6 Protection and Propagation of Fish, Shellf… ECOLOGICAL_… <df [2 × 4]>        
#>  7 Protection of Human Health related to Cons… FISHCONSUMP… <df [1 × 4]>        
#>  8 Seasonal Migratory Fish Spawning and Nurse… ECOLOGICAL_… <df [1 × 4]>        
#>  9 Seasonal Shallow-Water Submerged Aquatic V… ECOLOGICAL_… <df [1 × 4]>        
#> 10 Secondary Contact Recreation and Aesthetic… RECREATION_… <df [2 × 4]>        
#> 11 Water Contact Sports                        RECREATION_… <df [1 × 4]>        
#> 
#> $summaryByParameterImpairments
#> # A tibble: 16 × 4
#>    parameterGroupName catchmentSizeSqMi catchmentSizePercent assessmentUnitCount
#>    <chr>                          <dbl>                <dbl>               <int>
#>  1 ALGAL GROWTH                    9.22                20.0                    2
#>  2 CHLORINE                        1.73                 3.75                   1
#>  3 HABITAT ALTERATIO…             18.8                 40.7                    1
#>  4 HYDROLOGIC ALTERA…             18.8                 40.7                    1
#>  5 METALS (OTHER THA…             15.5                 33.6                   12
#>  6 NUTRIENTS                      30.3                 65.7                    5
#>  7 OIL AND GREASE                 11.0                 23.7                    2
#>  8 ORGANIC ENRICHMEN…             30.3                 65.7                    5
#>  9 PATHOGENS                      35.2                 76.4                   15
#> 10 PER- AND POLYFLUO…              1.00                 2.18                   2
#> 11 PESTICIDES                     16.2                 35.1                   11
#> 12 POLYCHLORINATED B…             16.9                 36.6                   13
#> 13 SALINITY/TOTAL DI…             18.8                 40.7                    1
#> 14 TOXIC ORGANICS                 13.3                 28.7                    8
#> 15 TRASH                          28.6                 61.9                    4
#> 16 TURBIDITY                      34.9                 75.6                   13
#> 
#> $summaryRestorationPlans
#> # A tibble: 1 × 4
#>   summaryTypeName catchmentSizeSqMi catchmentSizePercent assessmentUnitCount
#>   <chr>                       <dbl>                <dbl>               <int>
#> 1 TMDL                         15.9                 34.4                  13
#> 
#> $summaryVisionRestorationPlans
#> # A tibble: 1 × 4
#>   summaryTypeName catchmentSizeSqMi catchmentSizePercent assessmentUnitCount
#>   <chr>                       <dbl>                <dbl>               <int>
#> 1 TMDL                         15.9                 34.4                  13
```

[`huc12_summary()`](https://mps9506.github.io/rATTAINS/reference/huc12_summary.md)
returns a list of tibbles with different summaries of information. Using
the above example: - `x$huc_summary` provides a summary of HUC area, and
the area and percentage of catchment assessed as good, unknown, or
impaired. - `x$au_summary` provides a tibble with the unique identifiers
for the assessment units (or distinct sections of waterbodies) within
the queried HUC12. - `x$ir_summary` provides a simple summary of the
area of the catchment classified under different Integrated Report
Categories. - `x$status_summary` provides a summary of the overall
status within the HUC12. - `x$use_group_summary` provides a summary of
use attainment bu use group within the HUC12. - `x$use_summary` breaks
the use summary down further by the use name. - `x$param_summary`
provides the same information for parameter groups. -
`x$res_plan_summary` and `x$vision_plan_summary` provides a summary of
the amount of the watershed covered by particular types of restoration
plans or vision plan, such as TMDLs.

### Domains

Each function has a number of allowable arguments and associated values.
In order to explore what values you might be interested in querying, the
Domain Value service provides information about allowable options. This
is mapped to the
[`domain_values()`](https://mps9506.github.io/rATTAINS/reference/domain_values.md)
function. When used without any arguments you get a full list of
possible “domains.” These are typically searchable parameters used in
all the functions in rATTAINS. Note that the domain names returned by
these service are not a one to one match with the argument names used in
rATTAINS. It is typically fairly easy to figure out which ones match up
to which arguments.

For example if I want to find out the possible organization identifiers
to query by:

``` r
x <- domain_values(domain_name = "OrgStateCode")
x
#> # A tibble: 157 × 6
#>    domain       name  code  context      context2 dateModified
#>    <chr>        <chr> <chr> <chr>        <chr>    <chr>       
#>  1 OrgStateCode AK    AK    EPA          EPA      2017-08-28  
#>  2 OrgStateCode FL    FL    21FL303D     State    2025-01-29  
#>  3 OrgStateCode PA    PA    EPA          EPA      2017-08-28  
#>  4 OrgStateCode MT    MT    BLCKFEET     Tribe    2024-04-09  
#>  5 OrgStateCode CC    CC    TEST_ORG_C   Test     2017-08-28  
#>  6 OrgStateCode AZ    AZ    TEST_TRIBE_B Tribe    2017-10-18  
#>  7 OrgStateCode OK    OK    ESTO         Tribe    2024-04-09  
#>  8 OrgStateCode MS    MS    21MSWQ       State    2017-08-28  
#>  9 OrgStateCode CT    CT    CT_DEP01     State    2020-02-25  
#> 10 OrgStateCode ND    ND    21NDHDWQ     State    2024-06-19  
#> # ℹ 147 more rows
```

The function returns a variable with the state codes and the possible
parameter values as the context variable. Similarly if I want to look up
possible Use Names that are utilized by the Texas Commission on
Environmental Quality:

``` r
x <- domain_values(domain_name = "UseName", context = "TCEQMAIN")
x
#> # A tibble: 1,357 × 6
#>    domain  name                              code  context context2 dateModified
#>    <chr>   <chr>                             <chr> <chr>   <chr>    <chr>       
#>  1 UseName Primary Contact Recreation        Prim… 21DELA… RECREAT… 2017-08-28  
#>  2 UseName SECONDARY CONTACT (RECR)          SECO… CT_DEP… RECREAT… 2018-08-10  
#>  3 UseName Domestic Water Supply Waters      Dome… TEST_O… NA       2017-08-28  
#>  4 UseName Aquatic Life                      Aqua… HVTEPA  ECOLOGI… 2017-12-08  
#>  5 UseName Hydroelectric Power Generation    Hydr… MEDEP   OTHER_U… 2017-08-28  
#>  6 UseName Aquatic Life: Lake Sturgeon Wate… Aqua… LRBOI   ECOLOGI… 2021-01-06  
#>  7 UseName Outstanding Tribal Resource Wate… Outs… TAOSPB… OTHER_U… 2021-01-06  
#>  8 UseName Wildlife                          Wild… WIDNR   ECOLOGI… 2022-05-23  
#>  9 UseName Aquatic Life                      Aqua… POLSWA… ECOLOGI… 2021-01-06  
#> 10 UseName Drinking Water                    Drin… PUEBLO… DRINKIN… 2022-09-15  
#> # ℹ 1,347 more rows
```

### Other Services

- [`assessment_units()`](https://mps9506.github.io/rATTAINS/reference/assessment_units.md)
  : provides information about assessment units by the specified
  argument parameters.

- [`assessments()`](https://mps9506.github.io/rATTAINS/reference/assessments.md)
  provides information about assessment decisions by the specified
  argument parameters.

- [`actions()`](https://mps9506.github.io/rATTAINS/reference/actions.md)
  provides information about Actions (such as TMDLs, 4B Actions, or
  similar) that have been finalized by the specified argument
  parameters.

- [`plans()`](https://mps9506.github.io/rATTAINS/reference/plans.md) is
  similiar to actions but provides information about finalized Actions
  and assessment units by HUC8.

- [`surveys()`](https://mps9506.github.io/rATTAINS/reference/surveys.md)
  provides information about organization conducted statistical surveys
  about water quality assessment results.

### JSON Files

By default, all the functions rATTAINS return one or more “tidy”
dataframes. These dataframe are created by attempting to flatten the
nested JSON data returned by the webservice. This does require some
opinionated decisions on what constitutes flat data, and at what
variable data should be flattened to. We recognize that the dataframe
output might not meet user needs. There if you would prefer to parse the
JSON data yourself, use the `tidy=FALSE` argument to return an unparsed
JSON string. A number of R packages are available to parse and flatten
JSON data to prepare it for analysis.

## Notes

The U.S. EPA is the data provider for this public information. rATTAINS
and the author are not affiliated with the EPA. Questions about the
package functionality should be directed to the package author.
Questions about the webservice or underlying data should be directed to
the U.S. EPA. Please do not abuse the webservice using this package.
