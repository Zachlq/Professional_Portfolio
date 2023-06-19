import json
import os
import gspread
from oauth2client.service_account import ServiceAccountCredentials
import pandas as pd
from gspread_dataframe import set_with_dataframe, get_as_dataframe
import pandas as pd 
import os
import logging
import google.cloud.logging
import json 
from google.cloud import storage 
from google.cloud import bigquery
import mintapi as mintapi
from googleapiclient import discovery
import requests
import config as cfg
import time

start_time = time.time()

os.environ["GOOGLE_APPLICATION_CREDENTIALS"]=cfg.creds

logging.basicConfig(format='%(asctime)s %(levelname)s:%(message)s', level=logging.DEBUG, datefmt='%I:%M:%S')

client = google.cloud.logging.Client()
client.setup_logging()

bq_client = bigquery.Client()

bucket = storage.Client().get_bucket(cfg.bucket)
blob = bucket.blob(cfg.file)
token = json.loads(blob.download_as_string())

def upload_to_bq(df: pd.DataFrame, dataset_id: str, table_id: str, schema: list):
    
    client = bigquery.Client()

    dataset_ref = client.dataset(dataset_id)
    table_ref = dataset_ref.table(table_id)

    job_config = bigquery.LoadJobConfig()
    job_config.write_disposition='WRITE_APPEND'
    job_config.source_format = bigquery.SourceFormat.CSV
    job_config.schema = schema
    job_config.ignore_unknown_values=True 

    job = client.load_table_from_dataframe(
    df,
    table_ref,
    location='US',
    job_config=job_config)
    
    return job.result()

def get_article_ids():
    
    gc = gspread.service_account(cfg.creds, cfg.scope)
    sh = gc.open_by_url(cfg.sheet_url).sheet1
    
    df = pd.DataFrame(sh.get_all_records())

    article_ids = df['id'].to_list()
    
    return article_ids

def make_request():
    
    logging.info("Getting article ids...")
    
    ids = get_article_ids()
    
    df = pd.DataFrame()
    
    for i in ids:
        
        url = f"https://medium2.p.rapidapi.com/article/{i}"
        
        logging.info(f"Making request with Medium id: {i}")

        req = requests.request("GET", url, headers=token)
        
        res = req.json()
        
        logging.info(f"Response: {req.status_code}")

        i_d = res['id']
        tags = res['tags']
        claps = res['claps']
        last_modified_at = res['last_modified_at']
        published_at = res['published_at']
        url = res['url']
        image_url = res['image_url']
        is_series = res['is_series']
        lang = res['lang']
        publication_id = res['publication_id']
        word_count = res['word_count']
        is_locked = res['is_locked']
        title = res['title']
        reading_time = res['reading_time']
        responses_count = res['responses_count']
        voters = res['voters']
        topics = res['topics']
        author = res['author']
        subtitle = res['subtitle']

        df = df.append({
            "id": i_d,
            "tags": tags,
            "claps": claps,
            "last_modified_at": last_modified_at,
            "published_at": published_at,
            "url": url,
            "image_url": image_url,
            "is_series": is_series,
            "lang": lang,
            "publication_id": publication_id,
            "word_count": word_count,
            "is_locked": is_locked,
            "title": title,
            "reading_time": reading_time,
            "responses_count": responses_count,
            "voters": voters,
            "topics": topics,
            "author": author,
            "subtitle": subtitle
        }, ignore_index=True)
            
    
    return df
        
def main(event, context):
    
    medium_df = make_request()
    
    for i in cfg.bools:
        medium_df[i] = medium_df[i].astype(bool)
    
    medium_df['dt_updated'] = pd.Timestamp.now("US/Eastern")
    
    if len(medium_df) > 0:
        
        logging.info(f"Article data frame created. Uploading to {cfg.dataset}.{cfg.table}...")
    
        upload_to_bq(medium_df, cfg.dataset, cfg.table, cfg.medium_schema)
        
        logging.info(f"{cfg.dataset}.{cfg.table} updated for {cfg.today}.")

        end_time = time.time() - start_time
            
        status = True

        num_req = len(medium_df.id)
        
        dt_updated = pd.Timestamp.now("US/Eastern")

        data = {"requests": num_req, "success": status, "run_time": end_time, "updated_time": dt_updated}

        log_df = pd.DataFrame(data=data, index=[0])
                     
        logging.info(f"Uploading medium log to {cfg.dataset}.{cfg.log_table}")

        upload_to_bq(log_df, cfg.dataset, cfg.log_table, cfg.log_schema)
                     
        logging.info(f"Medium tables updated for {cfg.today}")
        
    else:
        
        logging.info("Retry function!")
        
if __name__ == "__main__": 
    logging.info(f"Beginning execution for {cfg.today}")
    main("","")
