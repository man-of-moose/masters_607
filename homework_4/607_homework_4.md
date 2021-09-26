---
title: "607_homework_4"
author: "Alec"
date: "9/21/2021"
output: 
  prettydoc::html_pretty:
    theme: cosmo
    highlight: github
    keep_md: true
    toc: true
    toc_depth: 2
    df_print: paged
---



# Israeli Population research

## Total Population

9.053 Million

source: https://en.wikipedia.org/wiki/Demographics_of_Israel

## Who is eligible for vaccine?

Persons 12 years or older

source: https://govextra.gov.il/ministry-of-health/covid19-vaccine/en-covid19-vaccination-information/

## How many are eligible for vaccine?

28% are under 14 years old. So we know that atleast 72% (1.00 - 0.28) of the population is eligible.

This would equate roughly to [9,053,000 * 0.72] = 6,518,160 eligible persons

# load libraries


```r
library(tidyverse)
```

```
## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──
```

```
## ✓ ggplot2 3.3.5     ✓ purrr   0.3.4
## ✓ tibble  3.1.4     ✓ dplyr   1.0.7
## ✓ tidyr   1.1.3     ✓ stringr 1.4.0
## ✓ readr   2.0.1     ✓ forcats 0.5.1
```

```
## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

```r
library(stringr)
```


# Reading and Cleaning Data


```r
il_vax <- read_csv("https://raw.githubusercontent.com/man-of-moose/masters_607/main/homework_4/efficacy_data_clean.csv")
```

```
## New names:
## * `` -> ...3
## * `` -> ...5
```

```
## Rows: 5 Columns: 6
```

```
## ── Column specification ────────────────────────────────────────────────────────
## Delimiter: ","
## chr (6): Age, Population %, ...3, Severe Cases, ...5, Efficacy
```

```
## 
## ℹ Use `spec()` to retrieve the full column specification for this data.
## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

### Inspect the table


```r
il_vax
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["Age"],"name":[1],"type":["chr"],"align":["left"]},{"label":["Population %"],"name":[2],"type":["chr"],"align":["left"]},{"label":["...3"],"name":[3],"type":["chr"],"align":["left"]},{"label":["Severe Cases"],"name":[4],"type":["chr"],"align":["left"]},{"label":["...5"],"name":[5],"type":["chr"],"align":["left"]},{"label":["Efficacy"],"name":[6],"type":["chr"],"align":["left"]}],"data":[{"1":"NA","2":"Not Vax\\n%","3":"Fully Vax\\n%","4":"Not Vax\\nper 100K\\n\\n\\np","5":"Fully Vax\\nper 100K","6":"vs. severe disease"},{"1":"<50","2":"1116834","3":"3501118","4":"43","5":"11","6":"NA"},{"1":"NA","2":"0.233","3":"0.73","4":"NA","5":"NA","6":"NA"},{"1":">50","2":"186078","3":"2133516","4":"171","5":"290","6":"NA"},{"1":"NA","2":"0.079","3":"0.904","4":"NA","5":"NA","6":"NA"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>


### Fill in age column using fill()

This replaces any Null values with the value above it.


```r
il_vax <- il_vax %>% fill(Age)
```

### Remove the first row

This row does not contain any useful information. It's better to remove, and to rename columns


```r
il_vax <- il_vax[-1,]
colnames(il_vax) <- c("age","not_vax","vax","severe_no_vax","severe_vax","efficacy")
```


```r
il_vax
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["age"],"name":[1],"type":["chr"],"align":["left"]},{"label":["not_vax"],"name":[2],"type":["chr"],"align":["left"]},{"label":["vax"],"name":[3],"type":["chr"],"align":["left"]},{"label":["severe_no_vax"],"name":[4],"type":["chr"],"align":["left"]},{"label":["severe_vax"],"name":[5],"type":["chr"],"align":["left"]},{"label":["efficacy"],"name":[6],"type":["chr"],"align":["left"]}],"data":[{"1":"<50","2":"1116834","3":"3501118","4":"43","5":"11","6":"NA"},{"1":"<50","2":"0.233","3":"0.73","4":"NA","5":"NA","6":"NA"},{"1":">50","2":"186078","3":"2133516","4":"171","5":"290","6":"NA"},{"1":">50","2":"0.079","3":"0.904","4":"NA","5":"NA","6":"NA"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

### Temporarily split out population count values with their percent counterparts


```r
vac_percentages <- il_vax[-c(1,3),] %>%
                      select(age,not_vax,vax)

il_vax <- il_vax[c(1,3),]
```


```r
vac_percentages
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["age"],"name":[1],"type":["chr"],"align":["left"]},{"label":["not_vax"],"name":[2],"type":["chr"],"align":["left"]},{"label":["vax"],"name":[3],"type":["chr"],"align":["left"]}],"data":[{"1":"<50","2":"0.233","3":"0.73"},{"1":">50","2":"0.079","3":"0.904"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

```r
il_vax
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["age"],"name":[1],"type":["chr"],"align":["left"]},{"label":["not_vax"],"name":[2],"type":["chr"],"align":["left"]},{"label":["vax"],"name":[3],"type":["chr"],"align":["left"]},{"label":["severe_no_vax"],"name":[4],"type":["chr"],"align":["left"]},{"label":["severe_vax"],"name":[5],"type":["chr"],"align":["left"]},{"label":["efficacy"],"name":[6],"type":["chr"],"align":["left"]}],"data":[{"1":"<50","2":"1116834","3":"3501118","4":"43","5":"11","6":"NA"},{"1":">50","2":"186078","3":"2133516","4":"171","5":"290","6":"NA"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>


### use gather() function to convert il_vax and vac_percentages to long

First we will convert vac_percentaes to long


```r
vac_percentages <- vac_percentages %>%
  gather("vax_status","age_pop_percent",2:3) %>%
  mutate(
    age_pop_percent = as.double(age_pop_percent)
  )
```


```r
vac_percentages
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["age"],"name":[1],"type":["chr"],"align":["left"]},{"label":["vax_status"],"name":[2],"type":["chr"],"align":["left"]},{"label":["age_pop_percent"],"name":[3],"type":["dbl"],"align":["right"]}],"data":[{"1":"<50","2":"not_vax","3":"0.233"},{"1":">50","2":"not_vax","3":"0.079"},{"1":"<50","2":"vax","3":"0.730"},{"1":">50","2":"vax","3":"0.904"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>


Then we can use the same techniques to convert il_vax to long. Here we use gather twice, once for vax_status, and another for severe cases.


```r
il_vax <- il_vax %>% 
  gather("vax_status","pop_count",2:3) %>%
  gather("severe_cases","severe_count",2:3)
```


```r
il_vax
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["age"],"name":[1],"type":["chr"],"align":["left"]},{"label":["efficacy"],"name":[2],"type":["chr"],"align":["left"]},{"label":["vax_status"],"name":[3],"type":["chr"],"align":["left"]},{"label":["pop_count"],"name":[4],"type":["chr"],"align":["left"]},{"label":["severe_cases"],"name":[5],"type":["chr"],"align":["left"]},{"label":["severe_count"],"name":[6],"type":["chr"],"align":["left"]}],"data":[{"1":"<50","2":"NA","3":"not_vax","4":"1116834","5":"severe_no_vax","6":"43"},{"1":">50","2":"NA","3":"not_vax","4":"186078","5":"severe_no_vax","6":"171"},{"1":"<50","2":"NA","3":"vax","4":"3501118","5":"severe_no_vax","6":"43"},{"1":">50","2":"NA","3":"vax","4":"2133516","5":"severe_no_vax","6":"171"},{"1":"<50","2":"NA","3":"not_vax","4":"1116834","5":"severe_vax","6":"11"},{"1":">50","2":"NA","3":"not_vax","4":"186078","5":"severe_vax","6":"290"},{"1":"<50","2":"NA","3":"vax","4":"3501118","5":"severe_vax","6":"11"},{"1":">50","2":"NA","3":"vax","4":"2133516","5":"severe_vax","6":"290"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

### Remove redundant rows

Using gather() on severe_cases was important for making this dataframe long, but it also created a number of redundant rows. We use filter to choose only rows where vax_status matches severe_cases (vax -> vax, or no_vax -> no_vax)

We can then remove the column severe_cases, because severe_count holds the actual value we care about.

We can finally create a new column which is the proportion of severe_cases to total group population.


```r
il_vax <- il_vax %>%
  filter((vax_status=="not_vax" & severe_cases=="severe_no_vax") | 
          (vax_status=="vax" & severe_cases=="severe_vax")) %>%
  select(age,vax_status,pop_count,severe_count) %>%
  mutate(
    pop_count = as.integer(pop_count),
    severe_count = as.integer(severe_count),
    severe_count_prop = severe_count / pop_count
  )
```


```r
il_vax
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["age"],"name":[1],"type":["chr"],"align":["left"]},{"label":["vax_status"],"name":[2],"type":["chr"],"align":["left"]},{"label":["pop_count"],"name":[3],"type":["int"],"align":["right"]},{"label":["severe_count"],"name":[4],"type":["int"],"align":["right"]},{"label":["severe_count_prop"],"name":[5],"type":["dbl"],"align":["right"]}],"data":[{"1":"<50","2":"not_vax","3":"1116834","4":"43","5":"3.850169e-05"},{"1":">50","2":"not_vax","3":"186078","4":"171","5":"9.189695e-04"},{"1":"<50","2":"vax","3":"3501118","4":"11","5":"3.141854e-06"},{"1":">50","2":"vax","3":"2133516","4":"290","5":"1.359259e-04"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

### Merge vax_table and vac_percentages

We can now combine back in the population vaccination percentages by age, captured in the vax_percentages table.



```r
il_vax <- left_join(il_vax,vac_percentages,by=c("age","vax_status")) %>%
              select(age, 
                     vax_status, 
                     pop_count, 
                     age_pop_percent, 
                     severe_count, 
                     severe_count_prop)
```


```r
il_vax
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["age"],"name":[1],"type":["chr"],"align":["left"]},{"label":["vax_status"],"name":[2],"type":["chr"],"align":["left"]},{"label":["pop_count"],"name":[3],"type":["int"],"align":["right"]},{"label":["age_pop_percent"],"name":[4],"type":["dbl"],"align":["right"]},{"label":["severe_count"],"name":[5],"type":["int"],"align":["right"]},{"label":["severe_count_prop"],"name":[6],"type":["dbl"],"align":["right"]}],"data":[{"1":"<50","2":"not_vax","3":"1116834","4":"0.233","5":"43","6":"3.850169e-05"},{"1":">50","2":"not_vax","3":"186078","4":"0.079","5":"171","6":"9.189695e-04"},{"1":"<50","2":"vax","3":"3501118","4":"0.730","5":"11","6":"3.141854e-06"},{"1":">50","2":"vax","3":"2133516","4":"0.904","5":"290","6":"1.359259e-04"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

# Questions

## Do you have enough information to calculate total population? What does this total population represent?

Yes, we can calculate the population of "individuals eligible for vaccination in Israel" based on the data that we have here.


```r
calculate_total_population <- function(age_group, data) {
  temp_table <- data %>% filter(age==age_group)
  pop_count_sum <- sum(temp_table$pop_count)
  age_pop_percent_sum <- sum(temp_table$age_pop_percent)
  
  return(pop_count_sum/age_pop_percent_sum)
}
```


```r
calculate_total_population("<50",il_vax) + 
  calculate_total_population(">50",il_vax)
```

```
## [1] 7155090
```

This does not match our expected population of 6.5M for total eligible voters shown at the start of this assignment (and sourced from wikipedia). However, that statistic was generated using the proportion of people ages 0-14, where for this problem we are actually interested in the proportion of people ages 0-12.


## Calculate the Efficacy vs Disease; Explain your results

In order to keep our data tidy, we need to create a new table for efficacy. We can always join this table to the other one later.


```r
efficacy_table <- tibble(
  age = unique(il_vax$age)
)
```


```r
calculate_efficacy <- function(age_group, table) {
  vax_prop <- table %>%
                filter(age==age_group & vax_status=="vax") %>%
                .$severe_count_prop
  
  no_vax_prop <- table %>%
                filter(age==age_group & vax_status=="not_vax") %>%
                .$severe_count_prop
  
  ret <- 1-(vax_prop/no_vax_prop)
  
  return(ret)
}
```


```r
efficacy_table <- efficacy_table %>% 
  mutate(efficacy = calculate_efficacy(age,il_vax))
```


```r
efficacy_table
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["age"],"name":[1],"type":["chr"],"align":["left"]},{"label":["efficacy"],"name":[2],"type":["dbl"],"align":["right"]}],"data":[{"1":"<50","2":"0.9183970"},{"1":">50","2":"0.8520888"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
As we can see from the above efficacy_table, vaccines are incredibly effective for both age groups. Interpreting the above data, we can say that:

- vaccines prevent 91% of severe cases for individuals under 50 years of age.
- vaccines prevent 85% of severe cases for individuals over 50 years of age.


## From your calculation of efficacy vs disease, are you able to compare the rate of severe cases in unvaccinted individuals to that in vaccinated individuals?

Yes, by comparing the proportions of [severe_count / pop_count] between vaccinated and unvaccinated peoples we can see the difference in severe cases rate.


```r
under_50_not_vax_severe_proportion <- il_vax %>%
  filter(age=="<50", vax_status=="not_vax") %>%
  .$severe_count_prop

under_50_vax_severe_proportion <- il_vax %>%
  filter(age=="<50", vax_status=="vax") %>%
  .$severe_count_prop


# comparing difference in proportions

under_50_not_vax_severe_proportion / under_50_vax_severe_proportion
```

```
## [1] 12.25445
```

In the under-50 bracket, unvaccinated people end up with severe cases at a rate 12 times greater than vaccinated people.


```r
over_50_not_vax_severe_proportion <- il_vax %>%
  filter(age==">50", vax_status=="not_vax") %>%
  .$severe_count_prop

over_50_vax_severe_proportion <- il_vax %>%
  filter(age==">50", vax_status=="vax") %>%
  .$severe_count_prop


# comparing difference in proportions

over_50_not_vax_severe_proportion / over_50_vax_severe_proportion
```

```
## [1] 6.760814
```

In the over-50 bracket, unvaccinated people end up with severe cases at a rate 6 times greater than vaccinated people.

