---
title: "607_homework_7"
author: "Alec"
date: "10/10/2021"
output: 
  prettydoc::html_pretty:
    theme: cosmo
    highlight: github
    keep_md: true
    toc: true
    toc_depth: 2
    df_print: paged
---




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
library(XML)
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


# Part 1 - Pick Books

Pick three of your favorite books on one of your favorite subjects. At least one of the books should have more than one author. For each book, include the title, authors, and two or three other attributes that you find
interesting.


```r
books <- read_csv("book_data.csv", show_col_types = FALSE)

books
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["title"],"name":[1],"type":["chr"],"align":["left"]},{"label":["author"],"name":[2],"type":["chr"],"align":["left"]},{"label":["publish_date"],"name":[3],"type":["dbl"],"align":["right"]},{"label":["num_pages"],"name":[4],"type":["dbl"],"align":["right"]},{"label":["goodreads_rating"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["num_ratings"],"name":[6],"type":["dbl"],"align":["right"]}],"data":[{"1":"Good Omens","2":"Neil Gaiman, Terry Pratchett","3":"2019","4":"288","5":"4.2","6":"608611"},{"1":"The Shadow Over Innsmouth","2":"HP Lovecraft","3":"1936","4":"64","5":"4.1","6":"13810"},{"1":"At the Mountain of Madness","2":"HP Lovecraft","3":"1936","4":"102","5":"3.9","6":"39758"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

# Part 2 - Create HTML, XML, JSON representations

Take the information that you’ve selected about these three books, and separately create three files which store the book’s information in HTML (using an html table), XML, and JSON formats (e.g. “books.html”,“books.xml”, and “books.json”).

## HTML

### Manually write HTML

Sample HTML code using html-table below:


```r
<html>
    <head>
        <title>books</title>
    </head>
    <body>
        <table>
            <tr>    <th>title</th> <th>author</th> <th>publish_date</th> <th>num_pages</th> <th>goodreads_rating</th> <th>num_ratings</th>    </tr>
            <tr>    <td>Good Omens</td> <td>Neil Gaiman, Terry Pratchett</td> <td>2019</td> <td>288</td> <td>4.2</td> <td>608,611</td>    </tr>
            <tr>    <td>The Shadow Over Innsmouth</td> <td>HP Lovecraft</td> <td>1936</td> <td>64</td> <td>4.1</td> <td>13,810</td>    </tr>
            <tr>    <td>At The Mountain of Madness</td> <td>HP Lovecraft</td> <td>1936</td> <td>102</td> <td>3.9</td> <td>39,758</td>    </tr>     
        </table>
    </body>
</html>
```

### Load HTML into dataframe


```r
parsed_html_table <- XML::htmlParse("books.html")

html_books_df <- XML::readHTMLTable(parsed_html_table)

html_books_df <- html_books_df[[1]]
```



```r
html_books_df
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["title"],"name":[1],"type":["chr"],"align":["left"]},{"label":["author"],"name":[2],"type":["chr"],"align":["left"]},{"label":["publish_date"],"name":[3],"type":["chr"],"align":["left"]},{"label":["num_pages"],"name":[4],"type":["chr"],"align":["left"]},{"label":["goodreads_rating"],"name":[5],"type":["chr"],"align":["left"]},{"label":["num_ratings"],"name":[6],"type":["chr"],"align":["left"]}],"data":[{"1":"Good Omens","2":"Neil Gaiman, Terry Pratchett","3":"2019","4":"288","5":"4.2","6":"608,611"},{"1":"The Shadow Over Innsmouth","2":"HP Lovecraft","3":"1936","4":"64","5":"4.1","6":"13,810"},{"1":"At The Mountain of Madness","2":"HP Lovecraft","3":"1936","4":"102","5":"3.9","6":"39,758"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

## XML

### Manually write XML

Sample XML code:


```r
<?xml version="1.0" encoding="ISO-8859-1"?>
<books>
    <book id="1">
        <title>Good Omens</title>
        <Author>Neil Gaiman, Terry Pratchett</Author>
        <publish_date>2019</publish_date>
        <num_pages>288</num_pages>
        <goodreads_rating>4.2</goodreads_rating>
        <num_ratings>608,611</num_ratings>
    </book>
    <book id="2">
        <title>The Shadow Over Innsmouth</title>
        <Author>HP Lovecraft</Author>
        <publish_date>1936</publish_date>
        <num_pages>64</num_pages>
        <goodreads_rating>4.1</goodreads_rating>
        <num_ratings>13,810</num_ratings>
    </book>
    <book id="3">
        <title>At The Mountain of Madness</title>
        <Author>HP Lovecraft</Author>
        <publish_date>1936</publish_date>
        <num_pages>102</num_pages>
        <goodreads_rating>3.9</goodreads_rating>
        <num_ratings>39,758</num_ratings>
    </book>
</books>
```

### Load HTML into dataframe


```r
parsed_xml_table <- XML::xmlParse("books.xml")

xml_books_df <- XML::xmlToDataFrame(parsed_xml_table)
```



```r
xml_books_df
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["title"],"name":[1],"type":["chr"],"align":["left"]},{"label":["author"],"name":[2],"type":["chr"],"align":["left"]},{"label":["publish_date"],"name":[3],"type":["chr"],"align":["left"]},{"label":["num_pages"],"name":[4],"type":["chr"],"align":["left"]},{"label":["goodreads_rating"],"name":[5],"type":["chr"],"align":["left"]},{"label":["num_ratings"],"name":[6],"type":["chr"],"align":["left"]}],"data":[{"1":"Good Omens","2":"Neil Gaiman, Terry Pratchett","3":"2019","4":"288","5":"4.2","6":"608,611"},{"1":"The Shadow Over Innsmouth","2":"HP Lovecraft","3":"1936","4":"64","5":"4.1","6":"13,810"},{"1":"At The Mountain of Madness","2":"HP Lovecraft","3":"1936","4":"102","5":"3.9","6":"39,758"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
## JSON

### Manually write JSON

Sample JSON code:


```r
{"books" :[
    {
    "title" : "Good Omens",
    "author" : "Neil Gaiman, Terry Pratchett",
    "publish_date" : 2019,
    "num_pages" : 288,
    "goodreads_rating" : 4.2,
    "num_ratings" : 608611
    },
    {
    "title" : "The Shadow Over Innsmouth",
    "author" : "HP Lovecraft",
    "publish_date" : 1936,
    "num_pages" : 64,
    "goodreads_rating" : 4.1,
    "num_ratings" : 13810
    },
    {
    "title" : "At The Mountain of Madness",
    "author" : "HP Lovecraft",
    "publish_date" : 1936,
    "num_pages" : 102,
    "goodreads_rating" : 3.9,
    "num_ratings" : 39758
    }]
}
```

### Load JSON into dataframe


```r
json_books_df <- jsonlite::fromJSON("books.json")$books
```


```r
json_books_df
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["title"],"name":[1],"type":["chr"],"align":["left"]},{"label":["author"],"name":[2],"type":["chr"],"align":["left"]},{"label":["publish_date"],"name":[3],"type":["int"],"align":["right"]},{"label":["num_pages"],"name":[4],"type":["int"],"align":["right"]},{"label":["goodreads_rating"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["num_ratings"],"name":[6],"type":["int"],"align":["right"]}],"data":[{"1":"Good Omens","2":"Neil Gaiman, Terry Pratchett","3":"2019","4":"288","5":"4.2","6":"608611","_rn_":"1"},{"1":"The Shadow Over Innsmouth","2":"HP Lovecraft","3":"1936","4":"64","5":"4.1","6":"13810","_rn_":"2"},{"1":"At The Mountain of Madness","2":"HP Lovecraft","3":"1936","4":"102","5":"3.9","6":"39758","_rn_":"3"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

# Are all tables identical?


```r
all.equal(html_books_df, xml_books_df)
```

```
## [1] TRUE
```

html_books_df and xml_books_df are identical


```r
all.equal(html_books_df, json_books_df)
```

```
## [1] "Component \"publish_date\": Modes: character, numeric"                  
## [2] "Component \"publish_date\": target is character, current is numeric"    
## [3] "Component \"num_pages\": Modes: character, numeric"                     
## [4] "Component \"num_pages\": target is character, current is numeric"       
## [5] "Component \"goodreads_rating\": Modes: character, numeric"              
## [6] "Component \"goodreads_rating\": target is character, current is numeric"
## [7] "Component \"num_ratings\": Modes: character, numeric"                   
## [8] "Component \"num_ratings\": target is character, current is numeric"
```

The JSON dataframe is different than the other two. The primary difference has to do with the type differences for some of the columns. Specifically, JSON was able to properly convey the correct type (numerical) to publish_date, num_pages, goodreads_rating, and num_ratings.

Books with two authors separated by commas did not have any unique difficulties when parsing, across all inut data types.
