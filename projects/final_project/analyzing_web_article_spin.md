---
title: "Analyzing Bias in Online News"
author: "Alec"
date: "11/14/2021"
output: 
  prettydoc::html_pretty:
    theme: cosmo
    highlight: github
    keep_md: true
    toc: true
    toc_depth: 2
    df_print: paged
---



# Project Libraries


```r
library(stringr)
library(tidyverse)
library(dplyr)
library(tm)
library(stringr)
library(stringi)
library(SnowballC)
library(textstem)
library(sentimentr)
library(text2vec)
library(caret)
library(rvest)
library(tidytext)
library(randomForest)
library(topicmodels)
library(wordcloud)
library(wordcloud2)
library(grid)
library(gridExtra)
library(NLP)
set.seed(500)
```

# Project Summary

## Introduction

Much of today's online news media is consumed through social media channels. Unfortunately, it can be very difficult to determine bias when skimming through articles in your news feed. Combining this with the fact that most social media platforms today utilize algorithms that create feedback loops influencing which types of content a user views, we can see how easy it is for an individual to see their newsfeed quickly change to match whatever "bias" they've searched for, liked, or commented on in the past.

This can be particularly dangerous when considering news about public health trends. Taking the COVID pandemic as an example, we can see that online communities have become extremely polarized relative to subjects such as Vaccine Safety, Mask Effectiveness, and Virus Transmisibility. Depending on what type of news a person consumes, that person's perspective of the pandemic could be radically different than the perspective of another individual.

This projects aims to analyze the underlying differences in discource related to COVID by political leanings ("Left", "Right", and "Center"), and to develop a multi-class classification model to identify potential spin for new articles seen online.

## Data Collection

This project uses online news article data, sourced from 10 sources. Articles were scraped and enriched using Python, NewsAPI package, and Newspaper3k package (see github). 

The sources were tagged with guidance from allsides.com, a website that uses crowsdsourcing to vote for news source political leanings:


```r
sources_mapping <- c(
    "bbc-news" = "Center",
    "associated-press" = "Center",
    "the-american-conservative" = "Right",
    "national-review" = "Right",
    "breitbart-news" = "Right",
    "fox-news" = "Right",
    "cnn" = "Left",
    "the-washington-post" = "Left",
    "vice-news" = "Left",
    "buzzfeed" = "Left"
)
```

## Conclusion

From my analysis, I have determined that there are differences to the ways that various news sources portray information about COVID 19, depending on the assigned political leanings of the news source. Additionally, I have proven that machine learning models can be used that consider a document's text, text structure, sentiment, and emotion in order to classify political leaning.


In this study, multiple models were tested, including Regularized Logistic Regression, Random Forest, Bagged Logistic Regression, and Naive Bayes. Generally speaking, most models were able to improve upon our baseline classification threshold of 34%. Top models were able to score accuracy levels over 80%. This suggests that machine learning can be used to identify the different patterns of text and topic between news sources of differing political biases.


# Project Code

## Load Data


```r
article_data <- read_csv("https://raw.githubusercontent.com/man-of-moose/masters_607/main/projects/final_project/enriched_data.csv", show_col_types = FALSE)
```



```r
article_data %>%
  ggplot() +
  geom_bar(aes(x=target_response, fill=target_response))
```

![](analyzing_web_article_spin_files/figure-html/unnamed-chunk-4-1.png)<!-- -->

## Data Cleaning and Feature Engineering

### Initial Data Cleaning

Some of the articles were loaded with incorrectly formatted text. Here we replace any non UTF8 text with blank spaces.


```r
article_data <- article_data %>%
  select(-source_id) %>%
  mutate_if(
    is.character, ~gsub('[^ -~]', '', .))
```

For our classification, we will consider all text present in the document title, description, and content (sourced from NewsAPI). We will also consider the scraped "full text" (sourced from Newspaper3k).


```r
article_data <- article_data %>%
  mutate(
    text_predictor = str_c(title," ",description," ",content," ",full_text)
  )
```

### Feature Engineering

#### Document Structure Features

Understanding the structure of a document may be critical to classifying it's potential bias. Structure can include anything like "the length of the article", the "number of unique words", etc.

I believe that the total count of unique words in an article may be indicative of the political leanings of the article. We will create a function here that counts the total number of unique words from a document.


```r
unique_words_count <- function(string){
  string = str_replace_all(string, pattern = "[[:punct:]]", replacement= " ")
  string = str_replace_all(string, "\\s+", " ")
  string = str_trim(string)
  string = unlist(str_split(string, pattern= " "))
  unique_count = length(unique(string))
  
  return(unique_count)
}
```

I believe that the total count of unique lemmas in an article may be indicative of the political leanings of the article. We will create a function here that counts the total number of unique lemmas from a document.


```r
unique_lemmas_count <- function(string){
  string = str_replace_all(string, pattern = "[[:punct:]]", replacement= " ")
  string = str_replace_all(string, "\\s+", " ")
  string = str_trim(string)
  lemmas = lemmatize_strings(string, dictionary = lexicon::hash_lemmas)
  lemmas = unlist(str_split(lemmas, pattern= " "))
  unique_count = length(unique(lemmas))
  
  return(unique_count)
}
```

In addition to the total unique number of lemmas, I think that the total number of lemmas will also be interesting to review. Especially when we combine with total unique lemmas to get the ratio of unique to total.


```r
total_lemmas_count <- function(string){
  string = str_replace_all(string, pattern = "[[:punct:]]", replacement= " ")
  string = str_replace_all(string, "\\s+", " ")
  string = str_trim(string)
  lemmas = lemmatize_strings(string, dictionary = lexicon::hash_lemmas)
  lemmas = unlist(str_split(lemmas, pattern= " "))
  total_count = length(lemmas)
  
  return(total_count)
}
```

Here we apply the above functions to add a few additional features to our model.


```r
article_data <- article_data %>%
  mutate(
    predictor_length = str_length(str_replace_all(text_predictor, " ", "")),
    total_words = str_count(text_predictor, '\\w+'),
    avg_word_size = predictor_length / total_words,
    unique_words = unlist(lapply(text_predictor, unique_words_count)),
    unique_word_ratio = unique_words / total_words,
    total_lemmas = unlist(lapply(text_predictor, total_lemmas_count)),
    unique_lemmas = unlist(lapply(text_predictor, unique_lemmas_count)),
    unique_lemma_ratio = unique_lemmas / total_lemmas
  ) 
```

#### Sentiment Features

Using sentimentr package, we can easily apply sentiment analysis, including both sentiment scores as well as emotion classifications. We will additionally test to see if these features will provide any significance to our model.


```r
sentiment_data <- sentiment_by(article_data$text_predictor) %>%
  select(ave_sentiment)
```


```r
article_data <- cbind(article_data, sentiment_data)
```


```r
emotion_data <- emotion_by(article_data$text_predictor) %>%
  select(element_id, emotion_type, ave_emotion) %>%
  group_by(element_id) %>%
  pivot_wider(names_from = "emotion_type", values_from = "ave_emotion") %>%
  ungroup()
```


```r
colnames(emotion_data) <- str_c(colnames(emotion_data),"sent")
```


```r
article_data <- cbind(article_data, emotion_data)
```


## EDA

### Evaluating some of the Structural Features for importance

Evaluate if predictor_length is relevant in the model


```r
article_data %>%
  ggplot() +
  geom_boxplot(aes(x=predictor_length, fill=target_response))
```

![](analyzing_web_article_spin_files/figure-html/unnamed-chunk-16-1.png)<!-- -->


```r
anova <- aov(predictor_length ~ target_response, data = article_data)

summary(anova)
```

```
##                  Df    Sum Sq  Mean Sq F value Pr(>F)
## target_response   2 1.773e+07  8863469   0.847  0.429
## Residuals       415 4.340e+09 10458527
```

Based on the results of the ANOVA test, it seems that the predictor_length may not play a major role in the classification of documents (p-value > 0.05)


```r
article_data %>%
  ggplot() +
  geom_boxplot(aes(x=unique_word_ratio, fill=target_response))
```

![](analyzing_web_article_spin_files/figure-html/unnamed-chunk-18-1.png)<!-- -->


```r
anova <- aov(unique_word_ratio ~ target_response, data = article_data)

summary(anova)
```

```
##                  Df Sum Sq Mean Sq F value   Pr(>F)    
## target_response   2  0.283 0.14133   11.04 2.14e-05 ***
## Residuals       415  5.314 0.01281                     
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

Based on the results of the ANOVA test, it seems that the unique_word_ratio plays a major role in the classification of documents (p-value < 0.05)

### Visualizing Sentiment


```r
article_data %>%
  ggplot() +
  geom_boxplot(aes(x=ave_sentiment, fill=target_response), outlier.colour = "red")
```

![](analyzing_web_article_spin_files/figure-html/unnamed-chunk-20-1.png)<!-- -->


```r
anova <- aov(ave_sentiment ~ target_response, data = article_data)

summary(anova)
```

```
##                  Df Sum Sq  Mean Sq F value Pr(>F)
## target_response   2  0.000 0.000119   0.007  0.993
## Residuals       415  7.071 0.017038
```

Based on the results, sentiment doesn't seem to play a major role in the classification of political leanings. This goes against my expectations.


```r
article_data %>%
  ggplot() +
  geom_boxplot(aes(x=trust_negatedsent, fill=target_response), outlier.colour = "red")
```

![](analyzing_web_article_spin_files/figure-html/unnamed-chunk-22-1.png)<!-- -->


```r
anova <- aov(trust_negatedsent ~ target_response, data = article_data)

summary(anova)
```

```
##                  Df   Sum Sq   Mean Sq F value Pr(>F)  
## target_response   2 0.000032 1.599e-05   3.424 0.0335 *
## Residuals       415 0.001938 4.670e-06                 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

Emotion data can certainly be a help when classifying documents! As we can see here, it appears that articles from right leaning political sources score higher on the "trust_negated" index, which suggests that their articles have more doubt related to COVID news.

## Build a Corpus and conduct additional EDA

In order to use the new features that we created earlier, we will want to save them into their own dataframe. We will bind this 'additional_features' dataframe to the document term matrix that is producted using tm-package.


```r
additional_features <- article_data %>%
  select(
    predictor_length,total_words,avg_word_size,unique_words,unique_word_ratio,
    total_lemmas,unique_lemmas,unique_lemma_ratio,ave_sentiment,angersent,
    anger_negatedsent,anticipationsent,anticipation_negatedsent,disgustsent,
    disgust_negatedsent,fearsent,fear_negatedsent,joysent,joy_negatedsent,
    sadnesssent,sadness_negatedsent,surprisesent,surprise_negatedsent,
    trustsent,trust_negatedsent,target_response
  )
```

In order to use as many models later on, I will normalize these values with a custom min max function


```r
min_max_norm <- function(x) {
    (x - min(x)) / (max(x) - min(x))
  }
```


```r
additional_features_norm <- as.data.frame(lapply(additional_features%>%select(-target_response), min_max_norm))

additional_features_norm$target_response <- additional_features$target_response
```


We will use tm-package's stopwords, with some additional terms to ensure that we aren't classifying documents based simply on their source name.


```r
my_stopwords = tm::stopwords("english")

my_stopwords <- c(my_stopwords, "fox", "bbc", "apress","associated press","cnn","breitbart","vice","buzzfeed", "washington post", "li li")
```


And now we build the corpus using tm-package


```r
corpus <- VCorpus(VectorSource(article_data$text_predictor)) %>%
            tm_map(content_transformer(str_replace_all), 
                             pattern = "[^\\d]\\d{3}[^\\d]", 
                             replacement = " ") %>%
            tm_map(content_transformer(str_replace_all), 
                   pattern = "[<>$]+", 
                   replacement = " ") %>%
            # replace punctuation with spaces
            tm_map(content_transformer(str_replace_all), 
                   pattern = "[[:punct:]]", 
                   replacement = "") %>%
            # replace white spaces with single whitespaces
            tm_map(content_transformer(str_replace_all), 
                   pattern = "\\s+", 
                   replacement = " ") %>%
            # transform everything to lower case
            tm_map(content_transformer(tolower)) %>%
            # remove stopwords
            tm_map(content_transformer(removeWords), my_stopwords) %>%
            # stem
            tm_map(content_transformer(lemmatize_words))
```

In order to review by target_response later, we will append meta data to the documents.


```r
for (i in 1:length(corpus)){
  bias = article_data$target_response[i]
  
  meta(corpus[[i]], "target_response") <- bias
}
```


```r
left_corpus <- tm_filter(corpus, FUN = function(x) meta(x)[["target_response"]] == "Left")

right_corpus <- tm_filter(corpus, FUN = function(x) meta(x)[["target_response"]] == "Right")

center_corpus <- tm_filter(corpus, FUN = function(x) meta(x)[["target_response"]] == "Center")
```

Here were create a DocumentTermMatrix, and additionally create a final dataframe 'data' that includes the additional features we will want to test against later.

I create two version of the same matrix, once with word frequency, and once with TFIDF.

Additionally, I create a custom function in order to generate 1, 2-grams from the predictor text for modeling.


```r
BigramTokenizer <-
  function(x)
    unlist(lapply(ngrams(words(x), 1:2), paste, collapse = " "), use.names = FALSE)
```



```r
set.seed(500)
dtm <- DocumentTermMatrix(corpus, control=list(tokenize=BigramTokenizer))
dtm <- removeSparseTerms(dtm, 1-(4/length(corpus)))
data <- as.matrix(dtm)
data <- cbind(data, additional_features_norm)
data <- as.data.frame(data)
data$target_response <- as.factor(data$target_response)
names(data) <- make.names(names(data))
```


```r
set.seed(500)
dtm_tfidf = weightTfIdf(dtm, normalize = TRUE)
dtm_tfidf <- removeSparseTerms(dtm_tfidf, 1-(4/length(corpus)))
data_tfidf <- as.matrix(dtm_tfidf)
data_tfidf <- cbind(data_tfidf, additional_features_norm)
data_tfidf <- as.data.frame(data_tfidf)
data_tfidf$target_response <- as.factor(data_tfidf$target_response)
names(data_tfidf) <- make.names(names(data_tfidf))
```


For some of the models we want to test, it's important that we add a character to the start of each feature name. As an example, randomforest() function does not work with numerically named columns.


```r
response_col <- which(colnames(data) == "target_response")
colnames(data)[-response_col] <- paste0( "v", colnames(data)[-response_col])
```



```r
response_col <- which(colnames(data_tfidf) == "target_response")
colnames(data_tfidf)[-response_col] <- paste0( "v", colnames(data_tfidf)[-response_col])
```


### Wordclouds


```r
left_tdm <- TermDocumentMatrix(left_corpus, control=list(tokenize=BigramTokenizer))
left_tdm = weightTfIdf(left_tdm, normalize = TRUE)
left_tdm_matrix <- as.matrix(left_tdm) 
left_words <- sort(rowSums(left_tdm_matrix),decreasing=TRUE) 
left_df <- data.frame(word = names(left_words),freq=left_words)
```


```r
wordcloud(words = left_df$word, freq = left_df$freq, min.freq = 1, max.words= 200, scale=c(1.5,0.25), random.order=FALSE, rot.per=0.35,colors=brewer.pal(8, "Dark2"))
```

![](analyzing_web_article_spin_files/figure-html/unnamed-chunk-37-1.png)<!-- -->


```r
right_tdm <- TermDocumentMatrix(right_corpus, control=list(tokenize=BigramTokenizer))
right_tdm = weightTfIdf(right_tdm, normalize = TRUE)
right_tdm_matrix <- as.matrix(right_tdm) 
right_words <- sort(rowSums(right_tdm_matrix),decreasing=TRUE) 
right_df <- data.frame(word = names(right_words),freq=right_words)
```


```r
wordcloud(words = right_df$word, freq = right_df$freq, min.freq = 1, max.words= 200, scale=c(1.5,0.25), random.order=FALSE, rot.per=0.35,colors=brewer.pal(8, "Dark2"))
```

![](analyzing_web_article_spin_files/figure-html/unnamed-chunk-39-1.png)<!-- -->


```r
center_tdm <- TermDocumentMatrix(center_corpus, control=list(tokenize=BigramTokenizer))
center_tdm = weightTfIdf(center_tdm, normalize = TRUE)
center_tdm_matrix <- as.matrix(center_tdm) 
center_words <- sort(rowSums(center_tdm_matrix),decreasing=TRUE) 
center_df <- data.frame(word = names(center_words),freq=center_words)
```


```r
wordcloud(words = center_df$word, freq = center_df$freq, min.freq = 1, max.words= 200, scale=c(1.2,0.25), random.order=FALSE, rot.per=0.35,colors=brewer.pal(8, "Dark2"))
```

![](analyzing_web_article_spin_files/figure-html/unnamed-chunk-41-1.png)<!-- -->

### LDA Analysis - Topic Modeling

We can use the LDA function to perform lda analysis on our document term matrix. We will set an arbitrary value for the number of topics to be created as 6


```r
data_lda <- LDA(dtm, k = 5, control = list(seed=100))
data_lda
```

```
## A LDA_VEM topic model with 5 topics.
```


```r
word_topics <- tidy(data_lda, matrix = "beta")
```


```r
top_terms <- word_topics %>%
  group_by(topic) %>%
  slice_max(beta, n = 10) %>% 
  ungroup() %>%
  arrange(topic, -beta)

top_terms %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered()
```

![](analyzing_web_article_spin_files/figure-html/unnamed-chunk-44-1.png)<!-- -->


From the above charts, we can see which words are most related to each of the generated topics following LDA. We can use our own best judgement to categorize each of the topics.

Topic 1 - work, mandates

Topic 2 - interviews

Topic 3 - sports

Topic 4 - travel

Topic 5 - children


```r
document_gamma <- tidy(data_lda, matrix = "gamma")
```


```r
document_classification <- document_gamma %>%
  group_by(document) %>%
  slice_max(gamma) %>%
  ungroup() %>%
  mutate(
    document = as.integer(document)
  ) %>%
  arrange(document)
```


```r
document_classification$topic <- replace(document_classification$topic, document_classification$topic==1, "work, mandates")

document_classification$topic <- replace(document_classification$topic, document_classification$topic==2, "interviews")

document_classification$topic <- replace(document_classification$topic, document_classification$topic==3, "sports")

document_classification$topic <- replace(document_classification$topic, document_classification$topic==4, "travel")

document_classification$topic <- replace(document_classification$topic, document_classification$topic==5, "children")
```


```r
topic_models_data <- cbind(article_data, document_classification%>%select(topic))
```


```r
topic_models_data %>%
  ggplot() +
  geom_bar(aes(x=target_response, fill=target_response)) +
  facet_wrap(~topic, nrow=1) +
  theme(legend.position = "none") +
  coord_fixed(.1)
```

![](analyzing_web_article_spin_files/figure-html/unnamed-chunk-49-1.png)<!-- -->

## Testing Models

I will be testing 4 models, using both word frequency and tfidf document term matrices.


```r
dt = sort(sample(nrow(data), nrow(data)*.65))
train_data<-data[dt,]
test_data<-data[-dt,]
```


```r
dt = sort(sample(nrow(data_tfidf), nrow(data_tfidf)*.65))
train_data_tfidf<-data_tfidf[dt,]
test_data_tfidf<-data_tfidf[-dt,]
```

In order to visualize confusion matrices and associated model scoring, I will use the following custom function


```r
plot_confusion <- function(cm) {
  # extract the confusion matrix values as data.frame
  cm_d <- as.data.frame(t$table)
  # confusion matrix statistics as data.frame
  cm_st <-data.frame(t$overall)
  # round the values
  cm_st$t.overall <- round(cm_st$t.overall,2)
  # here we also have the rounded percentage values
  cm_p <- as.data.frame(prop.table(t$table))
  cm_d$Perc <- round(cm_p$Freq*100,2)
  
  cm_d_p <-  ggplot(data = cm_d, aes(x = Prediction , y =  Reference, fill = Freq))+
  geom_tile() +
  geom_text(aes(label = paste("",Freq)), color = 'green', size = 3) +
  theme_light() +
  guides(fill=FALSE) 

  # plotting the stats
  cm_st_p <-  tableGrob(cm_st)
  
  # all together
  grid.arrange(cm_d_p, cm_st_p,nrow = 1, ncol = 2, 
               top=textGrob("Confusion Matrix and Statistics",gp=gpar(fontsize=25,font=1)))
}
```

### Baseline

First I will compute the baseline accuracy and add that to our model tracker for review


```r
article_data %>%
  count(target_response) %>%
  mutate(
    n = (n/sum(n))**2
  ) %>%
  select(n) %>%
  sum()
```

```
## [1] 0.3471761
```


```r
model_tracking <- data.frame("model"=c("baseline"), "accuracy"=.3471)
```

We will be using 5-fold cross validation for all models


```r
train_control <- trainControl(method = "cv",
                              number = 5)
```


### Regularized Logistic Regression

#### Word Frequency


```r
regLog_model <- train(target_response~., 
                      data = train_data, 
                      method = 'regLogistic',
                      trControl = train_control)
```


```r
regLog_result <- predict(regLog_model, newdata = test_data%>%select(-target_response))
```


```r
t <- confusionMatrix(test_data$target_response, regLog_result)
accuracy <- t$overall[[1]]
```


```r
plot_confusion(t)
```

```
## Warning: `guides(<scale> = FALSE)` is deprecated. Please use `guides(<scale> =
## "none")` instead.
```

![](analyzing_web_article_spin_files/figure-html/unnamed-chunk-59-1.png)<!-- -->



```r
model_tracking <- rbind(model_tracking, c("reglog",accuracy))
```

#### TFIDF


```r
regLog_tfidf_model <- train(target_response~., 
                            data = train_data_tfidf, 
                            method = 'regLogistic',
                            trControl = train_control)
```


```r
regLog_tfidf_result <- predict(regLog_tfidf_model, newdata = test_data_tfidf%>%select(-target_response))
```


```r
t <- confusionMatrix(test_data$target_response, regLog_tfidf_result)
accuracy <- t$overall[[1]]
```


```r
plot_confusion(t)
```

```
## Warning: `guides(<scale> = FALSE)` is deprecated. Please use `guides(<scale> =
## "none")` instead.
```

![](analyzing_web_article_spin_files/figure-html/unnamed-chunk-64-1.png)<!-- -->


```r
model_tracking <- rbind(model_tracking, c("reglog_tfidf",accuracy))
```


### Random Forest

#### Word Frequency



```r
rf_model <- randomForest(target_response~., data = train_data)
```


```r
rf_result <- predict(rf_model, newdata = test_data%>%select(-target_response))
```


```r
t <- confusionMatrix(test_data_tfidf$target_response, rf_result)
accuracy <- t$overall[[1]]
```


```r
plot_confusion(t)
```

```
## Warning: `guides(<scale> = FALSE)` is deprecated. Please use `guides(<scale> =
## "none")` instead.
```

![](analyzing_web_article_spin_files/figure-html/unnamed-chunk-69-1.png)<!-- -->


```r
model_tracking <- rbind(model_tracking, c("randomforest",accuracy))
```

#### TFIDF


```r
rf_tfidf_model <- randomForest(target_response~., data = train_data_tfidf)
```


```r
rf_tfidf_result <- predict(rf_model, newdata = test_data_tfidf%>%select(-target_response))
```


```r
t <- confusionMatrix(test_data_tfidf$target_response, rf_tfidf_result)
accuracy <- t$overall[[1]]
```


```r
plot_confusion(t)
```

```
## Warning: `guides(<scale> = FALSE)` is deprecated. Please use `guides(<scale> =
## "none")` instead.
```

![](analyzing_web_article_spin_files/figure-html/unnamed-chunk-74-1.png)<!-- -->


```r
model_tracking <- rbind(model_tracking, c("randomforest_tfidf",accuracy))
```

### Bagged Logit Model

#### Word Frequency


```r
bagged_logic_model <- train(target_response~., 
                            data = train_data, 
                            method = 'LogitBoost',
                            trControl = train_control)
```


```r
bagged_logic_result <- predict(bagged_logic_model, newdata = test_data%>%select(-target_response))
```


```r
t <- confusionMatrix(test_data$target_response, bagged_logic_result)
accuracy <- t$overall[[1]]
```


```r
plot_confusion(t)
```

```
## Warning: `guides(<scale> = FALSE)` is deprecated. Please use `guides(<scale> =
## "none")` instead.
```

![](analyzing_web_article_spin_files/figure-html/unnamed-chunk-79-1.png)<!-- -->


```r
model_tracking <- rbind(model_tracking, c("bagged_logit",accuracy))
```


#### TFIDF


```r
bagged_logic_tfidf_model <- train(target_response~., 
                                  data = train_data_tfidf, 
                                  method = 'LogitBoost',
                                  trControl = train_control)
```


```r
bagged_logic_tfidf_result <- predict(bagged_logic_tfidf_model, newdata = test_data_tfidf%>%select(-target_response))
```


```r
t <- confusionMatrix(test_data_tfidf$target_response, bagged_logic_tfidf_result)
accuracy <- t$overall[[1]]
```


```r
plot_confusion(t)
```

```
## Warning: `guides(<scale> = FALSE)` is deprecated. Please use `guides(<scale> =
## "none")` instead.
```

![](analyzing_web_article_spin_files/figure-html/unnamed-chunk-84-1.png)<!-- -->


```r
model_tracking <- rbind(model_tracking, c("bagged_logit_tfidf",accuracy))
```


### Naive Bayes

#### Word Frequency


```r
nb_model <- train(target_response~., 
                  data = train_data, 
                  method = 'naive_bayes',
                  trControl = train_control)
```


```r
nb_results <- predict(nb_model, newdata = test_data%>%select(-target_response))
```


```r
t <- confusionMatrix(test_data$target_response, nb_results)
accuracy <- t$overall[[1]]
```


```r
plot_confusion(t)
```

```
## Warning: `guides(<scale> = FALSE)` is deprecated. Please use `guides(<scale> =
## "none")` instead.
```

![](analyzing_web_article_spin_files/figure-html/unnamed-chunk-89-1.png)<!-- -->


```r
model_tracking <- rbind(model_tracking, c("naive_bayes",accuracy))
```

#### TFIDF


```r
nb_tfidf_model <- train(target_response~., 
                        data = train_data_tfidf, 
                        method = 'naive_bayes',
                        trControl = train_control)
```


```r
nb_tfidf_results <- predict(nb_tfidf_model, newdata = test_data_tfidf%>%select(-target_response))
```


```r
t <- confusionMatrix(test_data_tfidf$target_response, nb_tfidf_results)
accuracy <- t$overall[[1]]
```


```r
plot_confusion(t)
```

```
## Warning: `guides(<scale> = FALSE)` is deprecated. Please use `guides(<scale> =
## "none")` instead.
```

![](analyzing_web_article_spin_files/figure-html/unnamed-chunk-94-1.png)<!-- -->


```r
model_tracking <- rbind(model_tracking, c("naive_bayes_tfidf",accuracy))
```


## Visualize Model Performance



```r
# Barplot
model_tracking %>%
  mutate(
    accuracy = as.double(accuracy),
    accuracy = round(accuracy,4)
    ) %>%
  ggplot(aes(x=model, y=accuracy)) + 
  geom_bar(aes(fill=model),stat = "identity") +
  geom_text(aes(label=accuracy)) + 
  coord_flip() +
  theme(axis.text.x = element_text(angle = 30, vjust = 0.5, hjust=.5)) +
  theme(legend.position = "none")
```

![](analyzing_web_article_spin_files/figure-html/unnamed-chunk-96-1.png)<!-- -->


