import pandas as pd
from newspaper import Article
from newspaper import Config
from urllib.request import urlopen
from bs4 import BeautifulSoup

# Define function that utilizes newspaper3k package to download news contents from site
def enrich_news_url(url):
    try:
        print("retrieving - {}".format(url))
        article = Article(url)
        article.download()
        article.parse()
        article.nlp()

        return article.text

    except (ValueError, Exception):
        return "401 Error"


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

# Read and perform initial data formatting
articles = pd.read_csv("more_articles.csv")
articles['source_id'] = articles['source'].apply(lambda x: eval(x)['id'])
articles['source_name'] = articles['source'].apply(lambda x: eval(x)['name'])
articles = articles[['source_id', 'source_name', 'author', 'title', 'description', 'url', 'publishedAt', 'content']]
articles['target'] = articles['source_id'].map(sources_mapping)


# Set user_agent with config
user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36'
config = Config()
config.browser_user_agent = user_agent


# Get full article contents using newspaper3k
articles['full_text'] = articles['url'].apply(enrich_news_url)
articles.to_csv("more_enriched_articles.csv")


breakpoint = 5
