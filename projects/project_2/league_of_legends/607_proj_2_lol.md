---
title: "Analyzing Champion Stats in League of Legends"
author: "Alec"
date: "10/3/2021"
output: 
  prettydoc::html_pretty:
    theme: cosmo
    highlight: github
    keep_md: true
    toc: true
    toc_depth: 2
    df_print: paged
---



# Introduction

Discussion Board Title: Analyzing Champion Stats in League of Legends

Dataset: https://ddragon.leagueoflegends.com/cdn/11.19.1/data/en_US/champion.json

Provided by: Santiago Torres

Suggested Prompt: "For all champions, figure out who has the highest starting hp for each tag category."


# Load Libaries

Load all required libraris into the evironment. For this dataset, we will be using json packages rjson and jsonlite for json parsing


```r
library(rjson)
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
library(jsonlite)
```

```
## 
## Attaching package: 'jsonlite'
```

```
## The following object is masked from 'package:purrr':
## 
##     flatten
```

```
## The following objects are masked from 'package:rjson':
## 
##     fromJSON, toJSON
```

# Load Data

Data is hosted on ddragon.leagueoflegends.com. We can use rjson::fromJSON to read and parse directly from the URL.

fromJSON will return a nested list structure containing all of the available json data


```r
champion_json <- rjson::fromJSON(file="https://ddragon.leagueoflegends.com/cdn/11.19.1/data/en_US/champion.json")
```

# Data Tidying

The first step in my tidy process will be to convert the champion_json list object into a "long" dataframe, containing the key-value pairs for all json elements


```r
unlisted_json <- enframe(unlist(champion_json))
```

As you can see below, every unique nested json element is notated using subsequent "."s.


```r
head(unlisted_json, 15)
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["name"],"name":[1],"type":["chr"],"align":["left"]},{"label":["value"],"name":[2],"type":["chr"],"align":["left"]}],"data":[{"1":"type","2":"champion"},{"1":"format","2":"standAloneComplex"},{"1":"version","2":"11.19.1"},{"1":"data.Aatrox.version","2":"11.19.1"},{"1":"data.Aatrox.id","2":"Aatrox"},{"1":"data.Aatrox.key","2":"266"},{"1":"data.Aatrox.name","2":"Aatrox"},{"1":"data.Aatrox.title","2":"the Darkin Blade"},{"1":"data.Aatrox.blurb","2":"Once honored defenders of Shurima against the Void, Aatrox and his brethren would eventually become an even greater threat to Runeterra, and were defeated only by cunning mortal sorcery. But after centuries of imprisonment, Aatrox was the first to find..."},{"1":"data.Aatrox.info.attack","2":"8"},{"1":"data.Aatrox.info.defense","2":"4"},{"1":"data.Aatrox.info.magic","2":"3"},{"1":"data.Aatrox.info.difficulty","2":"4"},{"1":"data.Aatrox.image.full","2":"Aatrox.png"},{"1":"data.Aatrox.image.sprite","2":"champion0.png"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

### What is the longest json object?

In order to create a "Hadley approved" long dataset, we will need to create enw columns to capture all of the nested json elements. In order to know how many columns to create, we need to know what the longest nested item is.


```r
dot_split_regex <- "\\."


n_cols_max <-
  unlisted_json %>%
  pull(name) %>%
  str_split(dot_split_regex) %>%
  map_dbl(~length(.)) %>%
  max()

n_cols_max
```

```
## [1] 4
```

### Use separate() function to split out the name column

separate() will split the name column into multiple columns based on the "." split. For items that do not have as many splits as n_cols_max, NA's will be introduced for the new columns


```r
split_champion_list <- unlisted_json %>% separate(name, into = c(paste0("x", 1:n_cols_max)),fill="right")
```


```r
head(split_champion_list,10)
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["x1"],"name":[1],"type":["chr"],"align":["left"]},{"label":["x2"],"name":[2],"type":["chr"],"align":["left"]},{"label":["x3"],"name":[3],"type":["chr"],"align":["left"]},{"label":["x4"],"name":[4],"type":["chr"],"align":["left"]},{"label":["value"],"name":[5],"type":["chr"],"align":["left"]}],"data":[{"1":"type","2":"NA","3":"NA","4":"NA","5":"champion"},{"1":"format","2":"NA","3":"NA","4":"NA","5":"standAloneComplex"},{"1":"version","2":"NA","3":"NA","4":"NA","5":"11.19.1"},{"1":"data","2":"Aatrox","3":"version","4":"NA","5":"11.19.1"},{"1":"data","2":"Aatrox","3":"id","4":"NA","5":"Aatrox"},{"1":"data","2":"Aatrox","3":"key","4":"NA","5":"266"},{"1":"data","2":"Aatrox","3":"name","4":"NA","5":"Aatrox"},{"1":"data","2":"Aatrox","3":"title","4":"NA","5":"the Darkin Blade"},{"1":"data","2":"Aatrox","3":"blurb","4":"NA","5":"Once honored defenders of Shurima against the Void, Aatrox and his brethren would eventually become an even greater threat to Runeterra, and were defeated only by cunning mortal sorcery. But after centuries of imprisonment, Aatrox was the first to find..."},{"1":"data","2":"Aatrox","3":"info","4":"attack","5":"8"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
  

### Get vectors for all interesting data points.

Below are all of the data points that we want to capture into vectors. The vectors should all be the same length, assuming that all champions have the same set of nested datapoints.

Following this assumption, it was discovered that not all data points are included for all champions! "tags" are not available for every champion, so for those items we will need a different approach.

- name
- title
- blurb
- tags***
-- hp
-- hpperlevel
-- mp
-- mpperlevel
--  movespeed
--  armor
--  armorperlevel
--  spellblock
--  spellblockperlevel
--  attackrange
--  hpregen
--  hpregenperlevel
--  mpregen
--  mpregenperlevel
-- crit
--  critperlevel
--  attackdamage
  


```r
champ_names <- split_champion_list %>%
  filter(x3 == "name") %>%
  select(value)
```


```r
champ_title <- split_champion_list %>%
  filter(x3 == "title") %>%
  select(value)
```


```r
champ_blurb <- split_champion_list %>%
  filter(x3 == "blurb") %>%
  select(value)
```


```r
champ_hp <- split_champion_list %>%
  filter(x4 == "hp") %>%
  select(value)
```


```r
champ_hpperlevel <- split_champion_list %>%
  filter(x4 == "hpperlevel") %>%
  select(value)
```


```r
champ_mp <- split_champion_list %>%
  filter(x4 == "mp") %>%
  select(value)
```


```r
champ_mpperlevel <- split_champion_list %>%
  filter(x4 == "mpperlevel") %>%
  select(value)
```


```r
champ_movespeed <- split_champion_list %>%
  filter(x4 == "movespeed") %>%
  select(value)
```


```r
champ_armor <- split_champion_list %>%
  filter(x4 == "armor") %>%
  select(value)
```


```r
champ_armorperlevel <- split_champion_list %>%
  filter(x4 == "armorperlevel") %>%
  select(value)
```


```r
champ_spellblock <- split_champion_list %>%
  filter(x4 == "spellblock") %>%
  select(value)
```


```r
champ_spellblockperlevel <- split_champion_list %>%
  filter(x4 == "spellblockperlevel") %>%
  select(value)
```


```r
champ_attackrange <- split_champion_list %>%
  filter(x4 == "attackrange") %>%
  select(value)
```


```r
champ_hpregen <- split_champion_list %>%
  filter(x4 == "hpregen") %>%
  select(value)
```


```r
champ_hpregenperlevel <- split_champion_list %>%
  filter(x4 == "hpregenperlevel") %>%
  select(value)
```


```r
champ_mpregen <- split_champion_list %>%
  filter(x4 == "mpregen") %>%
  select(value)
```


```r
champ_mpregenperlevel <- split_champion_list %>%
  filter(x4 == "mpregenperlevel") %>%
  select(value)
```


```r
champ_crit <- split_champion_list %>%
  filter(x4 == "crit") %>%
  select(value)
```


```r
champ_critperlevel <- split_champion_list %>%
  filter(x4 == "critperlevel") %>%
  select(value)
```


```r
champ_attackdamage <- split_champion_list %>%
  filter(x4 == "attackdamage") %>%
  select(value)
```
  
### Combine into one dataframe

We will combine all of the above generated vectors into the champ_names tibble. Note that we have still not addressed the problem with "tags".


```r
champs_tidy <- champ_names %>%
  mutate(
    title = pull(champ_title, value),
    blurb = pull(champ_blurb, value),
    hp = pull(champ_hp, value),
    hpperlevel = pull(champ_hpperlevel, value),
    mp = pull(champ_mp, value),
    mpperlevel = pull(champ_mpperlevel, value),
    movespeed = pull(champ_movespeed, value),
    armor = pull(champ_armor, value),
    armorperlevel = pull(champ_armorperlevel, value),
    spellblock = pull(champ_spellblock, value),
    spellblockperlevel = pull(champ_spellblockperlevel, value),
    attackrange = pull(champ_attackrange, value),
    hpregen = pull(champ_hpregen, value),
    hpregenperlevel = pull(champ_hpregenperlevel, value),
    mpregen = pull(champ_mpregen, value),
    mpregenperlevel = pull(champ_mpregenperlevel, value),
    crit = pull(champ_crit, value),
    critperlevel = pull(champ_critperlevel, value),
    attackdamage = pull(champ_attackdamage, value)
  )
```

### Get Tags data

Because some of the champions do not have tags listed, we need to create a special function to grab them


```r
get_tags1 <- function(champion_name) {
  a <- character(0)
  
  ret <- split_champion_list %>%
          filter(x2 == champion_name, x3 == "tags1") %>%
          pull(value)
  
  if (identical(a, ret)) {
    return("None")
  }
  
  return(unlist(ret))
}
```


```r
get_tags2 <- function(champion_name) {
  a <- character(0)
  
  ret <- split_champion_list %>%
          filter(x2 == champion_name, x3 == "tags2") %>%
          pull(value)
  
  if (identical(a, ret)) {
    return("None")
  }
  
  return(unlist(ret))
}
```

Now we are ready to use the above function to get correct tag vectors


```r
tags1 <- champs_tidy$value %>% lapply(FUN=get_tags1) %>% unlist()
```


```r
tags2 <- champs_tidy$value %>% lapply(FUN=get_tags2) %>% unlist()
```

And now we can add these vectors back into the champ_names dataframe


```r
champs_tidy$tags1 <- tags1
```


```r
champs_tidy$tags2 <- tags2
```

According to the poster's question, it appears that separating the tags items is not valuable for this analysis, and instead they should be concatenated.


```r
champs_tidy <- champs_tidy %>%
  mutate(
    tag_category = str_c(tags1," ",tags2)
  )
```


```r
champs_tidy <- champs_tidy %>%
  select(value, title, blurb, tag_category, everything(), -tags1, -tags2) %>%
  rename(name = value)
```

### View Tiday Data!

After all of the above steps, we now have a long dataset.


```r
head(champs_tidy, 5)
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["name"],"name":[1],"type":["chr"],"align":["left"]},{"label":["title"],"name":[2],"type":["chr"],"align":["left"]},{"label":["blurb"],"name":[3],"type":["chr"],"align":["left"]},{"label":["tag_category"],"name":[4],"type":["chr"],"align":["left"]},{"label":["hp"],"name":[5],"type":["chr"],"align":["left"]},{"label":["hpperlevel"],"name":[6],"type":["chr"],"align":["left"]},{"label":["mp"],"name":[7],"type":["chr"],"align":["left"]},{"label":["mpperlevel"],"name":[8],"type":["chr"],"align":["left"]},{"label":["movespeed"],"name":[9],"type":["chr"],"align":["left"]},{"label":["armor"],"name":[10],"type":["chr"],"align":["left"]},{"label":["armorperlevel"],"name":[11],"type":["chr"],"align":["left"]},{"label":["spellblock"],"name":[12],"type":["chr"],"align":["left"]},{"label":["spellblockperlevel"],"name":[13],"type":["chr"],"align":["left"]},{"label":["attackrange"],"name":[14],"type":["chr"],"align":["left"]},{"label":["hpregen"],"name":[15],"type":["chr"],"align":["left"]},{"label":["hpregenperlevel"],"name":[16],"type":["chr"],"align":["left"]},{"label":["mpregen"],"name":[17],"type":["chr"],"align":["left"]},{"label":["mpregenperlevel"],"name":[18],"type":["chr"],"align":["left"]},{"label":["crit"],"name":[19],"type":["chr"],"align":["left"]},{"label":["critperlevel"],"name":[20],"type":["chr"],"align":["left"]},{"label":["attackdamage"],"name":[21],"type":["chr"],"align":["left"]}],"data":[{"1":"Aatrox","2":"the Darkin Blade","3":"Once honored defenders of Shurima against the Void, Aatrox and his brethren would eventually become an even greater threat to Runeterra, and were defeated only by cunning mortal sorcery. But after centuries of imprisonment, Aatrox was the first to find...","4":"Fighter Tank","5":"580","6":"90","7":"0","8":"0","9":"345","10":"38","11":"3.25","12":"32","13":"1.25","14":"175","15":"3","16":"1","17":"0","18":"0","19":"0","20":"0","21":"60"},{"1":"Ahri","2":"the Nine-Tailed Fox","3":"Innately connected to the latent power of Runeterra, Ahri is a vastaya who can reshape magic into orbs of raw energy. She revels in toying with her prey by manipulating their emotions before devouring their life essence. Despite her predatory nature...","4":"Mage Assassin","5":"526","6":"92","7":"418","8":"25","9":"330","10":"21","11":"3.5","12":"30","13":"0.5","14":"550","15":"5.5","16":"0.6","17":"8","18":"0.8","19":"0","20":"0","21":"53"},{"1":"Akali","2":"the Rogue Assassin","3":"Abandoning the Kinkou Order and her title of the Fist of Shadow, Akali now strikes alone, ready to be the deadly weapon her people need. Though she holds onto all she learned from her master Shen, she has pledged to defend Ionia from its enemies, one...","4":"None None","5":"500","6":"105","7":"200","8":"0","9":"345","10":"23","11":"3.5","12":"37","13":"1.25","14":"125","15":"9","16":"0.9","17":"50","18":"0","19":"0","20":"0","21":"62"},{"1":"Akshan","2":"the Rogue Sentinel","3":"Raising an eyebrow in the face of danger, Akshan fights evil with dashing charisma, righteous vengeance, and a conspicuous lack of shirts. He is highly skilled in the art of stealth combat, able to evade the eyes of his enemies and reappear when they...","4":"Marksman Assassin","5":"560","6":"90","7":"350","8":"40","9":"330","10":"26","11":"3","12":"30","13":"0.5","14":"500","15":"3.75","16":"0.65","17":"8.175","18":"0.7","19":"0","20":"0","21":"52"},{"1":"Alistar","2":"the Minotaur","3":"Always a mighty warrior with a fearsome reputation, Alistar seeks revenge for the death of his clan at the hands of the Noxian empire. Though he was enslaved and forced into the life of a gladiator, his unbreakable will was what kept him from truly...","4":"Tank Support","5":"600","6":"106","7":"350","8":"40","9":"330","10":"44","11":"3.5","12":"32","13":"1.25","14":"125","15":"8.5","16":"0.85","17":"8.5","18":"0.8","19":"0","20":"0","21":"62"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

# Answer the Original Prompt:

Here we will be answering the original prompt, which is to determine which champions have the highest starting HP per category.


```r
champs_tidy %>%
  group_by(tag_category) %>%
  top_n(1, hp) %>%
  select(tag_category, name, hp)
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["tag_category"],"name":[1],"type":["chr"],"align":["left"]},{"label":["name"],"name":[2],"type":["chr"],"align":["left"]},{"label":["hp"],"name":[3],"type":["chr"],"align":["left"]}],"data":[{"1":"Mage Assassin","2":"Ahri","3":"526"},{"1":"Tank Support","2":"Alistar","3":"600"},{"1":"Tank Mage","2":"Amumu","3":"615"},{"1":"Marksman Support","2":"Ashe","3":"570"},{"1":"Mage Marksman","2":"Azir","3":"552"},{"1":"Support Tank","2":"Braum","3":"540"},{"1":"Mage Support","2":"Fiddlesticks","3":"580.4"},{"1":"Fighter Tank","2":"Garen","3":"620"},{"1":"Fighter Mage","2":"Gragas","3":"600"},{"1":"Support Mage","2":"Ivern","3":"585"},{"1":"Fighter Marksman","2":"Jayce","3":"560"},{"1":"Marksman Mage","2":"Jhin","3":"585"},{"1":"None None","2":"Jinx","3":"610"},{"1":"Assassin Mage","2":"Katarina","3":"602"},{"1":"Fighter Support","2":"Kayle","3":"600"},{"1":"Support Assassin","2":"Pyke","3":"600"},{"1":"Assassin Fighter","2":"Qiyana","3":"590"},{"1":"Mage Fighter","2":"Ryze","3":"575"},{"1":"Support Fighter","2":"Taric","3":"575"},{"1":"Fighter Assassin","2":"Tryndamere","3":"626"},{"1":"Marksman Assassin","2":"Twitch","3":"612"},{"1":"Tank Fighter","2":"Zac","3":"615"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>


