---
title: "607_homework_9"
author: "Alec"
date: "10/24/2021"
output: 
  prettydoc::html_pretty:
    theme: cosmo
    highlight: github
    keep_md: true
    toc: true
    toc_depth: 2
    df_print: paged
---



# Load libraries


```r
library(jsonlite)
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
## x dplyr::filter()  masks stats::filter()
## x purrr::flatten() masks jsonlite::flatten()
## x dplyr::lag()     masks stats::lag()
```

```r
library(stringr)
```


## Connecting to API


```r
key <- "APHySXOpNOGSc10kLBVm8ZdVljlRIRlf"
secret <- "2JYUVWVz9f6QGrkS"
```


```r
term <- "data-science"
begin <- "20210816"
end <- "20211024"
```


```r
base_url <- str_c("http://api.nytimes.com/svc/search/v2/articlesearch.json?q=", term, "&begin_date=", begin, "&end_date=", end, "&facet_filter=true&api-key=", key, sep="")
```


```r
data <- fromJSON(base_url, flatten=TRUE) %>% data.frame()
```

## Extracting data into dataframe


```r
initialQuery <- fromJSON(base_url)

maxPages <- round((initialQuery$response$meta$hits[1] / 10)-1) 

pages_2021 <- vector("list",length=maxPages)

for(i in 0:maxPages){
    nytSearch <- fromJSON(paste0(base_url, "&page=", i), flatten = TRUE) %>% data.frame()
    pages_2021[[i+1]] <- nytSearch
    Sys.sleep(5)
}
```


```r
nyt_2021_articles <- rbind_pages(pages_2021)
```


```r
head(nyt_2021_articles)
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["status"],"name":[1],"type":["chr"],"align":["left"]},{"label":["copyright"],"name":[2],"type":["chr"],"align":["left"]},{"label":["response.docs.abstract"],"name":[3],"type":["chr"],"align":["left"]},{"label":["response.docs.web_url"],"name":[4],"type":["chr"],"align":["left"]},{"label":["response.docs.snippet"],"name":[5],"type":["chr"],"align":["left"]},{"label":["response.docs.lead_paragraph"],"name":[6],"type":["chr"],"align":["left"]},{"label":["response.docs.print_section"],"name":[7],"type":["chr"],"align":["left"]},{"label":["response.docs.print_page"],"name":[8],"type":["chr"],"align":["left"]},{"label":["response.docs.source"],"name":[9],"type":["chr"],"align":["left"]},{"label":["response.docs.multimedia"],"name":[10],"type":["list"],"align":["right"]},{"label":["response.docs.keywords"],"name":[11],"type":["list"],"align":["right"]},{"label":["response.docs.pub_date"],"name":[12],"type":["chr"],"align":["left"]},{"label":["response.docs.document_type"],"name":[13],"type":["chr"],"align":["left"]},{"label":["response.docs.news_desk"],"name":[14],"type":["chr"],"align":["left"]},{"label":["response.docs.section_name"],"name":[15],"type":["chr"],"align":["left"]},{"label":["response.docs.type_of_material"],"name":[16],"type":["chr"],"align":["left"]},{"label":["response.docs._id"],"name":[17],"type":["chr"],"align":["left"]},{"label":["response.docs.word_count"],"name":[18],"type":["int"],"align":["right"]},{"label":["response.docs.uri"],"name":[19],"type":["chr"],"align":["left"]},{"label":["response.docs.subsection_name"],"name":[20],"type":["chr"],"align":["left"]},{"label":["response.docs.headline.main"],"name":[21],"type":["chr"],"align":["left"]},{"label":["response.docs.headline.kicker"],"name":[22],"type":["chr"],"align":["left"]},{"label":["response.docs.headline.content_kicker"],"name":[23],"type":["lgl"],"align":["right"]},{"label":["response.docs.headline.print_headline"],"name":[24],"type":["chr"],"align":["left"]},{"label":["response.docs.headline.name"],"name":[25],"type":["lgl"],"align":["right"]},{"label":["response.docs.headline.seo"],"name":[26],"type":["lgl"],"align":["right"]},{"label":["response.docs.headline.sub"],"name":[27],"type":["lgl"],"align":["right"]},{"label":["response.docs.byline.original"],"name":[28],"type":["chr"],"align":["left"]},{"label":["response.docs.byline.person"],"name":[29],"type":["list"],"align":["right"]},{"label":["response.docs.byline.organization"],"name":[30],"type":["chr"],"align":["left"]},{"label":["response.meta.hits"],"name":[31],"type":["int"],"align":["right"]},{"label":["response.meta.offset"],"name":[32],"type":["int"],"align":["right"]},{"label":["response.meta.time"],"name":[33],"type":["int"],"align":["right"]}],"data":[{"1":"OK","2":"Copyright (c) 2021 The New York Times Company. All Rights Reserved.","3":"For the Times food columnist J. Kenji López-Alt, the kitchen is also a lab, where an understanding of a few basics at the molecular level can make a difference in your next dish.","4":"https://www.nytimes.com/2021/08/16/insider/Kenji-Lopez-Alt-science-cooking.html","5":"For the Times food columnist J. Kenji López-Alt, the kitchen is also a lab, where an understanding of a few basics at the molecular level can make a difference in your next dish.","6":"J. Kenji López-Alt, a food columnist for The New York Times, approaches home cooking like a scientist. He explains the basic elements of food like proteins and fat and examines what happens to them on a molecular level during cooking — all in the name of making the best scrambled eggs, the best burger or a perfectly light schnitzel (the secret is vodka, among other things). He is also a James Beard award-winning cookbook author with a popular YouTube channel. Here, he talks about the influences that shaped his cooking, how he views science in the context of food and what he makes at home. This interview has been edited.","7":"A","8":"2","9":"The New York Times","10":"<df[,19] [74 × 19]>","11":"<df[,4] [12 × 4]>","12":"2021-08-16T09:00:12+0000","13":"article","14":"Summary","15":"Times Insider","16":"News","17":"nyt://article/a7a55d45-d694-5ec2-b64d-dffda48dd1aa","18":"800","19":"nyt://article/a7a55d45-d694-5ec2-b64d-dffda48dd1aa","20":"NA","21":"Cooking With a Dash of Science","22":"Times Insider","23":"NA","24":"Dishes With a Dash of Science","25":"NA","26":"NA","27":"NA","28":"By Katie Van Syckle","29":"<df[,8] [1 × 8]>","30":"NA","31":"365","32":"0","33":"50","_rn_":"1"},{"1":"OK","2":"Copyright (c) 2021 The New York Times Company. All Rights Reserved.","3":"In this episode, we’ll discuss what biopharma companies can learn from the disruption of the last year – harnessing what Accenture calls ‘New Science’ to rapidly discover and deliver revolutionary treatments to patients. Listen to learn more.","4":"https://www.nytimes.com/paidpost/accenture/built-for-change/how-new-science-is-changing-healthcare.html","5":"In this episode, we’ll discuss what biopharma companies can learn from the disruption of the last year – harnessing what Accenture calls ‘New Science’ to rapidly discover and deliver revolutionary treatments to patients. Listen to learn more.","6":"Episode Transcription","7":"NA","8":"NA","9":"NA","10":"<df[,0] [0 × 0]>","11":"<df[,0] [0 × 0]>","12":"2021-10-14T21:07:21+0000","13":"paidpost","14":"","15":"T Brand","16":"NA","17":"nyt://paidpost/5708ddaa-0d09-5e53-8161-8bf42790b533","18":"4965","19":"nyt://paidpost/5708ddaa-0d09-5e53-8161-8bf42790b533","20":"NA","21":"How ‘New Science’ Is Changing Healthcare","22":"Episode 8","23":"NA","24":"NA","25":"NA","26":"NA","27":"NA","28":"NA","29":"<df[,0] [0 × 0]>","30":"NA","31":"365","32":"0","33":"50","_rn_":"2"},{"1":"OK","2":"Copyright (c) 2021 The New York Times Company. All Rights Reserved.","3":"How could that change our understanding about, for starters, chronic disease, aging and obesity?","4":"https://www.nytimes.com/2021/09/14/magazine/calories-weight-age.html","5":"How could that change our understanding about, for starters, chronic disease, aging and obesity?","6":"It’s simple, we are often told: All you have to do to maintain a healthy weight is ensure that the number of calories you ingest stays the same as the number of calories you expend. If you take in more calories, or energy, than you use, you gain weight; if the output is greater than the input, you lose it. But while we’re often conscious of burning calories when we’re working out, 55 to 70 percent of what we eat and drink actually goes toward fueling all the invisible chemical reactions that take place in our body to keep us alive. “We think about metabolism as just being about exercise, but it’s so much more than that,” says Herman Pontzer, an associate professor of evolutionary anthropology at Duke University. “It’s literally the running total of how busy your cells are throughout the day.” Figuring out your total energy expenditure tells you how many calories you need to stay alive. But it also tells you “how the body is functioning,” Pontzer says. “There is no more direct measure of that than energy expenditure.”","7":"MM","8":"14","9":"The New York Times","10":"<df[,19] [74 × 19]>","11":"<df[,4] [7 × 4]>","12":"2021-09-14T09:00:11+0000","13":"article","14":"Magazine","15":"Magazine","16":"News","17":"nyt://article/8aa8d161-97e7-5c9f-b5c9-620186c2dec0","18":"1414","19":"nyt://article/8aa8d161-97e7-5c9f-b5c9-620186c2dec0","20":"NA","21":"The New Science on How We Burn Calories","22":"Studies Show","23":"NA","24":"The New Science on How We Burn Calories","25":"NA","26":"NA","27":"NA","28":"By Kim Tingley","29":"<df[,8] [1 × 8]>","30":"NA","31":"365","32":"0","33":"50","_rn_":"3"},{"1":"OK","2":"Copyright (c) 2021 The New York Times Company. All Rights Reserved.","3":"The National Counterintelligence and Security Center said American companies needed to better secure critical technologies as Beijing seeks to dominate the so-called bioeconomy.","4":"https://www.nytimes.com/2021/10/22/us/politics/china-genetic-data-collection.html","5":"The National Counterintelligence and Security Center said American companies needed to better secure critical technologies as Beijing seeks to dominate the so-called bioeconomy.","6":"BETHESDA, Md. — Chinese firms are collecting genetic data from around the world, part of an effort by the Chinese government and companies to develop the world’s largest bio-database, American intelligence officials reported on Friday.","7":"A","8":"9","9":"The New York Times","10":"<df[,19] [74 × 19]>","11":"<df[,4] [7 × 4]>","12":"2021-10-22T13:12:20+0000","13":"article","14":"Washington","15":"U.S.","16":"News","17":"nyt://article/42108ea1-2aa4-51bd-8099-e1487e754f46","18":"871","19":"nyt://article/42108ea1-2aa4-51bd-8099-e1487e754f46","20":"Politics","21":"U.S. Warns of Efforts by China to Collect Genetic Data","22":"NA","23":"NA","24":"U.S. Warns of Plan by the Chinese to Collect Genetic Data From Around the World","25":"NA","26":"NA","27":"NA","28":"By Julian E. Barnes","29":"<df[,8] [1 × 8]>","30":"NA","31":"365","32":"0","33":"50","_rn_":"4"},{"1":"OK","2":"Copyright (c) 2021 The New York Times Company. All Rights Reserved.","3":"The political dysfunction that holds America hostage also holds science hostage.","4":"https://www.nytimes.com/2021/09/10/opinion/covid-science-trust-us.html","5":"The political dysfunction that holds America hostage also holds science hostage.","6":"In the winter of 1848, a 26-year-old Prussian pathologist named Rudolf Virchow was sent to investigate a typhus epidemic raging in Upper Silesia, in what is now mostly Poland.","7":"SR","8":"2","9":"The New York Times","10":"<df[,19] [73 × 19]>","11":"<df[,4] [7 × 4]>","12":"2021-09-10T09:00:14+0000","13":"article","14":"OpEd","15":"Opinion","16":"Op-Ed","17":"nyt://article/0d70e775-40f2-5f55-86d5-a245d8c5ae96","18":"1265","19":"nyt://article/0d70e775-40f2-5f55-86d5-a245d8c5ae96","20":"NA","21":"Science Alone Can’t Heal a Sick Society","22":"Guest Essay","23":"NA","24":"Science Alone Can’t Heal a Sick Society","25":"NA","26":"NA","27":"NA","28":"By Jay S. Kaufman","29":"<df[,8] [1 × 8]>","30":"NA","31":"365","32":"0","33":"50","_rn_":"5"},{"1":"OK","2":"Copyright (c) 2021 The New York Times Company. All Rights Reserved.","3":"The responsibility for making decisions about getting boosters in some cases has shifted onto individuals and their doctors.","4":"https://www.nytimes.com/2021/09/24/opinion/covid-booster-shots.html","5":"The responsibility for making decisions about getting boosters in some cases has shifted onto individuals and their doctors.","6":"There’s finally a decision on which Americans should get booster shots against Covid-19. Unfortunately, some of the new federal recommendations go well beyond the data and foist the decision of appropriateness onto individuals and their doctors. And by expanding booster eligibility to a huge swath of the population, the Biden administration risks undermining confidence in vaccines.","7":"NA","8":"NA","9":"The New York Times","10":"<df[,19] [74 × 19]>","11":"<df[,4] [3 × 4]>","12":"2021-09-24T23:36:11+0000","13":"article","14":"OpEd","15":"Opinion","16":"Op-Ed","17":"nyt://article/1c770e0b-180c-51ec-ae77-d23155bed3b2","18":"979","19":"nyt://article/1c770e0b-180c-51ec-ae77-d23155bed3b2","20":"NA","21":"New Guidance on Booster Shots Gets Ahead of the Science","22":"Guest Essay","23":"NA","24":"NA","25":"NA","26":"NA","27":"NA","28":"By Megan L. Ranney and Jeremy Samuel Faust","29":"<df[,8] [2 × 8]>","30":"NA","31":"365","32":"0","33":"50","_rn_":"6"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>



