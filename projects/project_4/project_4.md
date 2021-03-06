---
title: "607 Project 4"
author: "Alec"
date: "11/12/2021"
output: 
  prettydoc::html_pretty:
    theme: cosmo
    highlight: github
    keep_md: true
    toc: true
    toc_depth: 1
    df_print: paged
---



# Project Introduction

Using available tools such as the tm-package and SnowballC, create a NLP model to perform Document Classification on emails. Emails are sourced from SpamAssassin, and are pre-tagged as being either 'spam' (spam email) or 'ham' (normal emails).


# Project

## Load libraries


```r
library(stringr)
library(tidyverse)
```

```
## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──
```

```
## ✓ ggplot2 3.3.5     ✓ purrr   0.3.4
## ✓ tibble  3.1.4     ✓ dplyr   1.0.7
## ✓ tidyr   1.1.3     ✓ forcats 0.5.1
## ✓ readr   2.0.1
```

```
## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

```r
library(dplyr)
library(tm)
```

```
## Loading required package: NLP
```

```
## 
## Attaching package: 'NLP'
```

```
## The following object is masked from 'package:ggplot2':
## 
##     annotate
```

```r
library(stringi)
library(SnowballC)
library(textstem)
```

```
## Loading required package: koRpus.lang.en
```

```
## Loading required package: koRpus
```

```
## Loading required package: sylly
```

```
## For information on available language packages for 'koRpus', run
## 
##   available.koRpus.lang()
## 
## and see ?install.koRpus.lang()
```

```
## 
## Attaching package: 'koRpus'
```

```
## The following object is masked from 'package:tm':
## 
##     readTagged
```

```
## The following object is masked from 'package:readr':
## 
##     tokenize
```



## Build helper functions

Small helper function during the data load process. Returns a collapsed version of the read emails.


```r
format_email_content <- function(emailContent){
  ret <- str_c(emailContent, collapse = " ")
  return(ret)
}
```

Small helper function that extracts the sender email from an email text document


```r
extract_sender_email <- function(email_list_converted){
  for (i in email_list_converted){
    #i <- str_trim(i, side = c("both"))
    if (str_detect(i, "From:")){
      ret <- str_extract(i, "[a-zA-Z\\-\\.\\d]+@[a-zA-Z\\-\\.]+")
      return(ret)
    }
  }
  
  return(NA)
}
```

Small helper function that extracts the receiver email from an email text document


```r
extract_receiver_email <- function(email_vector){
  for (i in email_vector){
    #i <- str_trim(i, side = c("both"))
    if (str_detect(i, "^To:")){
      ret <- str_extract(i, "[a-zA-Z\\-\\.\\d]+@[a-zA-Z\\-\\.]+")
      return(ret)
    }
  }
  
  return(NA)
}
```

Small helper function that extracts the email subject from an email text document


```r
extract_subject <- function(email_list_converted){
  for (i in email_list_converted){
    if (str_detect(i, "Subject:")){
      ret <- str_replace(i, "Subject:","")
      ret <- str_trim(ret, side=c("both"))
      return(ret)
    }
  }
  
  return(NA)
}
```


Wrapper function that connects the above functions into one. processs_files takes a provided file_path and target classification. It returns a character vector which is intended to be binded to a dataframe.


```r
process_files <- function(file_path, target){
  emailContents <- read_lines(file_path)
  sender <- extract_sender_email(emailContents)
  receiver <- extract_receiver_email(emailContents)
  subject <- extract_subject(emailContents)
  converted_full_text <- format_email_content(emailContents)
  target <- target
  
  ret <- c(file_path, subject, sender, receiver, converted_full_text, target)
  
  return(ret)
}
```

## Loading the data

Here we are reading the email data from our local machine. Ham files and Spam files are read separately.


```r
ham_files <- list.files(path="data/easy_ham_2", full.names = TRUE)
spam_files <- list.files(path="data/spam_2", full.names = TRUE)
```

We initialize an empty tibble that will hold our loaded data.


```r
ham_spam <- tibble(
  file_path = character(),
  subject = character(),
  sender = character(),
  receiver = character(),
  text = character(),
  target = character()
)
```

Here we iterate through each of the ham_file names. For each, we use process_file to extract relevant information. Finally, we use add_row() function to append the returned character vector to the ham_spam dataframe.


```r
for (file in ham_files){
  result = process_files(file, "ham")
  ham_spam <- ham_spam %>%
            add_row(
              file_path = result[1],
              subject = result[2],
              sender = result[3],
              receiver = result[4],
              text = result[5],
              target = result[6]
            )
}
```

We do the same for spam here. Notice that we are added the "spam" tag in the process_files() method. This way we can keep track of our data downstream.


```r
for (file in spam_files){
  result = process_files(file, "spam")
  ham_spam <- ham_spam %>%
            add_row(
              file_path = result[1],
              subject = result[2],
              sender = result[3],
              receiver = result[4],
              text = result[5],
              target = result[6]
            )
}
```

Due to file reading errors, some of the documents are not valid UTF-8. While there are likely other ways to deal with this, for now since it's only a small population of the emails, we will simply remove those items.


```r
ham_spam <- ham_spam %>%
              mutate(
                is_valid = validUTF8(text)
              ) %>%
              filter(
                is_valid == TRUE
              )
```


## Create a corpus

Using the tm-package, we can create a "corpus", or a collection of our documents. Here we've added a few proprocessing steps to the funnel, including: removing stop words. removing punctuation, removing excessive whitespace, lowercasing everything, and finally lemmatizing the words.


```r
corpus <- VCorpus(VectorSource(ham_spam$text)) %>%
            # remove stop words
            tm_map(content_transformer(removeWords), stopwords("english")) %>%
            # replace punctuation with spaces
            tm_map(content_transformer(str_replace_all), 
                   pattern = "[[:punct:]]", 
                   replacement = " ") %>%
            # replace white spaces with single whitespaces
            tm_map(content_transformer(str_replace_all), 
                   pattern = "\\s+", 
                   replacement = " ") %>%
            # transform everything to lower case
            tm_map(content_transformer(tolower)) %>%
            # stem
            tm_map(content_transformer(lemmatize_words))
```

## add tags

With the tm-package corpus object, every document held within can be provided additional "tags", or metadata. We will be adding the subject, sender, receiver, and target tags here.


```r
for (i in 1:length(corpus)){
  subject = ham_spam$subject[i]
  sender = ham_spam$sender[i]
  receiver = ham_spam$receiver[i]
  target = ham_spam$target[i]
  
  meta(corpus[[i]], "subject") <- subject
  meta(corpus[[i]], "sender") <- sender
  meta(corpus[[i]], "receiver") <- receiver
  meta(corpus[[i]], "target") <- target
}
```

Next we will scramble the corpus, rearranging documents randomly.


```r
scrambled_corpus <- corpus[sample(c(1:length(corpus)))]
```


```r
scrambled_corpus_prop <- scrambled_corpus %>%
  meta(tag = "target") %>%
  unlist() %>%
  table() 

scrambled_corpus_prop
```

```
## .
##  ham spam 
## 1281 1276
```


## Creating a Document Term Matrix

We will create a document term matrix, removing terms that occur less than 10 times in a document.


```r
dtm <- DocumentTermMatrix(scrambled_corpus)
```


```r
dtm <- removeSparseTerms(dtm, 1-(10/length(scrambled_corpus)))
```

We will also save the labels ("ham" / "spam") of the newly re-ordered documents.


```r
target_labels <- unlist(meta(scrambled_corpus, "target"))
```



```r
inspect(dtm)
```

```
## <<DocumentTermMatrix (documents: 2557, terms: 6056)>>
## Non-/sparse entries: 468908/15016284
## Sparsity           : 97%
## Maximal term length: 70
## Weighting          : term frequency (tf)
## Sample             :
##       Terms
## Docs   2002 com font>< http jul list localhost net org received
##   1261   11  17      0    5   0   18         7   0   2        9
##   1322    0 139     14   64   0   10         0  10   0        2
##   1347    0 136     14   68   4    0         0  16   4        2
##   2107   19  24     52   10  12   24         5  25   0       11
##   2248   16  20    260    4  16    6         5  25   0       16
##   2268   11  17      0    9  10    5         5  21   2        8
##   2272   14  18    260    4  14    6         5  26   0       14
##   2279    5 169    362  377   5    5         5  34   1        7
##   2280    5 169    362  377   5    2         5  34   1        7
##   2386    5   6    260    2   4    2         5   0   1        4
```

## Supervised learning


```r
library(RTextTools)
```

```
## Loading required package: SparseM
```

```
## 
## Attaching package: 'SparseM'
```

```
## The following object is masked from 'package:base':
## 
##     backsolve
```

```
## Registered S3 method overwritten by 'tree':
##   method     from
##   print.tree cli
```

```
## 
## Attaching package: 'RTextTools'
```

```
## The following objects are masked from 'package:SnowballC':
## 
##     getStemLanguages, wordStem
```

Here we create a container using the RTextTools package. This package makes it really easy to use a range of model-types for NLP classification.


```r
N <- length(target_labels)
split_point <- round(0.7*N) 

container <- create_container(
  dtm,
  labels = target_labels,
  trainSize = 1:split_point,
  testSize = split_point:N,
  virgin = FALSE
)
```

We will try using the SVM, Tree, and Boosting models available through RTextTools.


```r
svm_model <- train_model(container, "SVM")

tree_model <- train_model(container, "TREE")

boosting_model <- train_model(container, "BOOSTING")
```



```r
svm_out <- classify_model(container, svm_model)

tree_out <- classify_model(container, tree_model)

boosting_out <- classify_model(container, boosting_model)
```



```r
labels_out <- data.frame(
  correct_labels = target_labels[split_point:N],
  svm = as.character(svm_out[,1]),
  tree = as.character(tree_out[,1]),
  boosting = as.character(boosting_out[,1]),
  stringsAsFactors = FALSE
)
```

### SVM Performance


```r
prop.table(table(labels_out[,1]==labels_out[,2]))
```

```
## 
##      FALSE       TRUE 
## 0.01171875 0.98828125
```

### Tree Performance


```r
prop.table(table(labels_out[,1]==labels_out[,3]))
```

```
## 
##      FALSE       TRUE 
## 0.04166667 0.95833333
```

### Boosting Performance


```r
prop.table(table(labels_out[,1]==labels_out[,4]))
```

```
## 
##    FALSE     TRUE 
## 0.015625 0.984375
```

## Using tfidf instead of tf


```r
dtm_tfidf = weightTfIdf(dtm, normalize = TRUE)
```


```r
N <- length(target_labels)
split_point <- round(0.7*N) 

container_tfidf <- create_container(
  dtm_tfidf,
  labels = target_labels,
  trainSize = 1:split_point,
  testSize = split_point:N,
  virgin = FALSE
)
```



```r
svm_model_tfidf <- train_model(container_tfidf, "SVM")

tree_model_tfidf <- train_model(container_tfidf, "TREE")

boosting_model_tfidf <- train_model(container_tfidf, "BOOSTING")
```



```r
svm_out_tfidf <- classify_model(container_tfidf, svm_model_tfidf)

tree_out_tfidf <- classify_model(container_tfidf, tree_model_tfidf)

boosting_out_tfidf <- classify_model(container_tfidf, boosting_model_tfidf)
```


```r
labels_out_tfidf <- data.frame(
  correct_labels = target_labels[split_point:N],
  svm = as.character(svm_out_tfidf[,1]),
  tree = as.character(tree_out_tfidf[,1]),
  boosting = as.character(boosting_out_tfidf[,1]),
  stringsAsFactors = FALSE
)
```

### SVM Performance


```r
prop.table(table(labels_out_tfidf[,1]==labels_out_tfidf[,2]))
```

```
## 
##  FALSE   TRUE 
## 0.0625 0.9375
```

### Tree Performance


```r
prop.table(table(labels_out_tfidf[,1]==labels_out_tfidf[,3]))
```

```
## 
##      FALSE       TRUE 
## 0.03645833 0.96354167
```

### Boosting Performance


```r
prop.table(table(labels_out_tfidf[,1]==labels_out_tfidf[,4]))
```

```
## 
##      FALSE       TRUE 
## 0.01692708 0.98307292
```

## Conclusion

From the above analysis, we see that using NLP for document classification on these emails proves surprisingly effective. In the first iteration where we were using Bag-of-Words to make predictions, we saw that all three models performed very well, above 95% accuracy. Boosting performed the best with over 99%.

What was interesting was how the introduction of TFIDF weighting negatively impacted the prediciton accuracy. After applying TFIDF, all model accuracies decreased, with SVM suffering the most.
