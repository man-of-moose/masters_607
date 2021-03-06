---
title: "Recommendation Systems - OKCupid"
author: "Alec"
date: "11/7/2021"
output: 
  prettydoc::html_pretty:
    theme: cosmo
    highlight: github
    keep_md: true
    toc: true
    toc_depth: 1
    df_print: paged
---





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
```


## Perform Scenario Design

"Perform a Scenario Design analysis as described below.  Consider whether it makes sense for your selected recommender system to perform scenario design twice, once for the organization (e.g. Amazon.com) and once for the organization's customers."

```
Recommendation System: OKCupid.com

Who are the target users?: 
 - Singles

What are their key goals?: 
 - Connect with other singles looking for a relationship

How can you help them accomplish those goals?
- Utilize machine learning to provide relevant recommendations for users on the platform. Recommending people that have a high liklihood of being liked by the individual user.

The goals of the company (OKCupid) are the same as the goals of the goals of the users, in that we want to provide a service that provides relevant recommendations.

```


## Reverse Engineer the Site

"Attempt to reverse engineer what you can about the site, from the site interface and any available information that you can find on the Internet or elsewhere."

```
1. Site is explcitly targeted towards singles
2. Most of the images suggest a younger crowd, looking for hookups rather than long term relationships
3. Users are required to have a profile prior to viewing content
4. Information required at signup
  - Name
  - Gender
  - Birthdate
  - Location
  - Desired connection types:
    - Hookups
    - New Friends
    - Short-term dating
    - Long-term dating
  - What gender are you interested in
  - What age you are interested in
  - A photo of yourself
  - Personal introduction
  - Questions about upcoming relationship ()
    - About how long do you want your next relationship to last?
    - Which words describe you better?
    - How important is religion?
    - Are you ready to get married right now?
    - Do you enjoy discussing politics?
    - Would you date someone in considerable debt
    - Is astrological sign important in a match?
    - Which best describes your political beliefs?
    - Could you date someone who is really messy?
    - Which would you rather be? (Normal / Weird)
    - Are you currently employed?
    - Choose the better romantic activty (kissing paris, kissing tent)
    - Is jealousy healthy in a relationship?
    - Do you like scary movies?
    - Do you find yourself worrying about things that you have no control over?
    
5. Analyze the UX
  - Website offers a specialized search section where you can select groupings
    (vaccinated, pro-choice, online, etc)
  - Main section of the website is dedicated to the recommender system
    - Users are shown one recommendation at a time
    - Recommendations include the full profile of the recommended user
      - Name
      - Age
      - Location
      - Pictures
      - Self Summary
    - Users can either choose to pass, send an intro, or like the individual
    
6. Research the recommendation system
  - https://tech.okcupid.com/large-scale-collaborative-filtering-to-predict-who-on-okcupid-will-like-you-with-jax-88ac8a934044
  - Following this process
    - Randomly initialize everyone???s voter and votee vector
    - For some number of ???epochs??? (passes over the observed votes), we???ll go         through each vote we???ve observed, and
      - Compute the dot product between the voter???s voter vector and the
        votee???s votee vector
      - Compute the difference (error) between the dot product and the actual            outcome
      - Take the gradient of the error
        - This tells us how much each number in the vector contributed to the               error
        - We can use this as a ???direction??? to move the vector
      - Move opposite that direction by subtracting the gradient from the                vector
        - This will reduce (descend) the error
        - Notably, we don???t have to do this vote-by-vote, and instead can do a             bunch at a time by batching these computations.
        
    - Return the vectors we???ve learned for each voter and votee.
""

```

## Suggest improvements to the recommendation system

My suggestion would be to include additional steps in the registration process that allows uers to select pictures of people that they find attractive, sourced from a completely random group of profiles. Currently, the first people that you view on your profile are those that match highest against your introductory registration, which takes into account small personal details. By including image analysis upfront, the initial options would be more precise.

Also, especially within the context of hookups, a person's sexual taste will typically be more rigid than their musical taste. Implementing a search-based approach that uses keywords to identify "products" known to be liked (in this case girls in same age range as past selections, same race, same etc).






