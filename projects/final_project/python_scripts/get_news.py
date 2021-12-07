from newsapi import NewsApiClient
import pandas as pd

# set up API client
# API_KEY = "8f7a12bc8c884be7a7ba1eb3768ebc05"
API_KEY = "0ad9231da4f141e1947a4d32b11b5fa6"
master = NewsApiClient(api_key=API_KEY)

# get sources dataframe
sources = master.get_sources()
sources_df = pd.DataFrame(sources['sources'])

# set sources of interest
sources_mapping = {
    "bbc-news": "Center",
    "associated-press": "Center",
    "the-american-conservative": "Right",
    "national-review": "Right",
    "breitbart-news": "Right",
    "fox-news": "Right",
    "cnn": "Left",
    "the-washington-post": "Left",
    "vice-news": "Left",
    "buzzfeed": "Left"
}

article_jsons = []
for key, value in sources_mapping.items():
    articles_response = master.get_everything(q="covid",
                                  sources = key,
                                  language = "en",
                                  from_param='2021-11-05',
                                  sort_by="relevancy",
                                  page_size=50)

    articles_json_list = articles_response['articles']
    for i in articles_json_list:
        article_jsons.append(i)

articles_df = pd.DataFrame(article_jsons)

articles_df.to_csv("articles.csv")
