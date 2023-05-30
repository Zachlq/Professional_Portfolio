import pandas as pd 
import requests
import os 
import pydata_google_auth
from google.oauth2 import service_account
from google.cloud import language
import json 
from google.cloud import storage 
from google.cloud import bigquery
import news_config as cfg
import logging
from datetime import date

os.environ["GOOGLE_APPLICATION_CREDENTIALS"]="*************************"

logging.basicConfig(format='%(asctime)s %(message)s',level=logging.INFO)

current_dt = date.today()

bq_client = bigquery.Client()

def bq_load(table_id: str, df: pd.DataFrame):
    
    table_ref = bq_client.dataset("reddit_news")
    table_id = table_ref.table(table_id)
    
    job_config = bigquery.LoadJobConfig()
    job_config.write_disposition='WRITE_APPEND'
    job_config.source_format = bigquery.SourceFormat.CSV
    job_config.schema = cfg.schema

    job = bq_client.load_table_from_dataframe(
    df,
    table_id,
    location='US',
    job_config=job_config)
    
    return job.result()

def get_reddit_token():

    auth = requests.auth.HTTPBasicAuth('***********', '*************')
    data = {
    'grant_type': 'client_credentials',
    'username': cfg.user,
    'password': cfg.password
    }
    headers = {'User-Agent': 'News/0.0.1'}
    request = requests.post(cfg.base_access_url, auth=auth, data=data, headers=headers)
    token = request.json()['access_token']
    headers = {**headers, **{'Authorization': f"bearer {token}"}}
    
    return headers

def make_request(url: str):
    
    headers = get_reddit_token()

    request = requests.get(url, headers=headers, params={'limit': '100'})
    
    return request

def format_df(end_point: str):
    
    df = pd.DataFrame()
    
    for post in end_point.json()['data']['children']:
        df = df.append({
        'title': post['data']['title'],
        'upvote_ratio': post['data']['upvote_ratio'],
        'score': post['data']['score'],
        'ups': post['data']['ups'],
        'domain': post['data']['domain'],
        'num_comments': post['data']['num_comments']
    }, ignore_index=True)
        
    return df

def main():
    
    logging.info("Getting data for r/news...")
    
    # r/news.
    
    r_news = make_request(cfg.r_news)
    r_news_df = format_df(r_news)
    
    logging.info(f"r/news loaded successfully for {current_dt}. Getting data for r/nottheonion...")
    
    # r/nottheonion.
    
    not_the_onion = make_request(cfg.not_the_onion)
    nto_df = format_df(not_the_onion)
    
    logging.info(f"r/nottheonion loaded successfully for {current_dt}. Getting data for r/offbeat...")
    
    # r/offbeat.
    
    offbeat = make_request(cfg.offbeat)
    offbeat_df = format_df(offbeat)
    
    logging.info(f"r/offbeat loaded successfully for {current_dt}. Getting data for r/thenews...")
    
    # r/thenews.
    
    the_news = make_request(cfg.the_news)
    the_news_df = format_df(the_news)
    
    logging.info(f"r/thenews loaded successfully for {current_dt}. Getting data for r/USNews...")
    
    # r/USNews.
    
    us_news = make_request(cfg.us_news)
    us_news_df = format_df(us_news)
    
    logging.info(f"r/USNews loaded successfully for {current_dt}. Getting data for r/Full_news...")
    
    # r/Full_news
    
    full_news = make_request(cfg.full_news)
    full_news_df = format_df(full_news)
    
    logging.info(f"r/Full_news loaded successfully for {current_dt}. Getting data for r/quality_news...")
    
    # r/quality_news
    
    quality_news = make_request(cfg.quality_news)
    quality_news_df = format_df(quality_news)
    
    logging.info(f"r/quality_news loaded successfully for {current_dt}. Getting data for r/upliftingnews...")
    
    # r/uplifting_news
    
    uplifting_news = make_request(cfg.uplifting_news)
    uplifting_news_df = format_df(uplifting_news)
    
    logging.info(f"r/uplifting_news loaded successfully for {current_dt}. Getting data for r/inthenews...")
    
    # r/inthenews
    
    in_the_news = make_request(cfg.in_the_news)
    in_the_news_df = format_df(in_the_news)
    
    logging.info(f"r/inthenews loaded successfully. Creating dt_updated column...")
    
    data_frames = [r_news_df, nto_df, offbeat_df, the_news_df, us_news_df, full_news_df, quality_news_df,
                  uplifting_news_df, in_the_news_df]
    
    for df in data_frames:
        df["dt_updated"] = pd.Timestamp.today()
    
    logging.info(f"Deleting data for {current_dt}...")
                 
    # Delete data from today.
    
    for tab in cfg.tables:
        bq_client.query(
        """ 
        DELETE FROM `************.reddit_news."""+tab+"` WHERE dt_updated >= CURRENT_DATE('America/New_York')"
        
        )
    
    # Load all at once.
    
    logging.info("Loading to BigQuery...")
                 
    for tabs, dfs in zip(cfg.tables, data_frames):
        bq_load(tabs, dfs)
    
    logging.info(f"All tables loaded successfully for {current_dt}")

if __name__ == "__main__":
  logging.info(f"Getting data from Reddit API for {current_dt}")
  main()
