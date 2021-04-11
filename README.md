# idbr
An R interface to the US Census Bureau International Data Base API

<img src=tools/readme/idbr_sticker.png width="250">

<!-- badges: start -->
  [![R build status](https://github.com/walkerke/idbr/workflows/R-CMD-check/badge.svg)](https://github.com/walkerke/idbr/actions)![](http://www.r-pkg.org/badges/version/idbr)  ![](http://cranlogs.r-pkg.org/badges/idbr)
  <!-- badges: end -->

__Update: version 1.0 introduces a re-written and re-factored package API.  Functions from earlier versions of the package are deprecated and not recommended for use.__

This R package enables users to fetch international demographic indicators from the US Census Bureau's International Data Base API and return R data frames.  Total population data are available from 1950-2100 (projected); age-group subsets and other demographic indicators are available for varying periods by country.  

Install from CRAN with: 

```r
install.packages('idbr')
```

Or get the development version from GitHub: 

```r
library(devtools)
install_github('walkerke/idbr')
```

## Basic usage: 

To get started, load __idbr__ and set your Census API key with the `idb_api_key()` function.  An API key can be obtained from the US Census Bureau at <http://api.census.gov/data/key_signup.html>.  tidycensus users can use their existing API keys which idbr will pick up if already installed.

```r
library(idbr)

idb_api_key('Your API key goes here')
```

The core function used in idbr is `get_idb()`.  This function grants access to two core APIs.  The first is the single-year-of-age API, which returns population counts by single-year age bands, subsetted optionally by sex and age range.   This dataset is well-suited for analyses and visualizations of the age composition of countries, such as population pyramids: 

```r
library(idbr)
library(tidyverse)

china_data <- get_idb(
  country = "China",
  year = 2021,
  age = 0:100,
  sex = c("male", "female")
) 

china_data %>%
  mutate(pop = ifelse(sex == "Male", pop * -1, pop)) %>%
  ggplot(aes(x = pop, y = as.factor(age), fill = sex)) + 
  geom_col(width = 1) + 
  theme_minimal(base_size = 15) + 
  scale_x_continuous(labels = function(x) paste0(abs(x / 1000000), "m")) + 
  scale_y_discrete(breaks = scales::pretty_breaks(n = 10)) + 
  scale_fill_manual(values = c("red", "gold")) + 
  labs(title = "Population structure of China in 2021",
       x = "Population",
       y = "Age",
       fill = "")


```

<img src="https://walker-data.com/img/china_pyramid.png">

`get_idb()` also grants access to the five-year-age-band dataset, which includes a wide range of fertility, mortality, and migration indicators along with overall population counts.  In turn, it can be used to inform analyses of how demographic indicators vary by country, among many other use cases. The argument `geometry = TRUE` can be used to return country boundaries as simple features along with your data which is helpful for mapping global and regional trends.  

```r
library(idbr)
library(tidyverse)

lex <- get_idb(
  country = "all",
  year = 2021,
  variables = c("name", "e0"),
  geometry = TRUE
)

ggplot(lex, aes(fill = e0)) + 
  theme_bw() + 
  geom_sf() + 
  coord_sf(crs = 'ESRI:54030') + 
  scale_fill_viridis_c() + 
  labs(fill = "Life expectancy \nat birth (2021)")
```

<img src="https://walker-data.com/img/lex_map.png">


