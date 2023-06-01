import requests 
import pandas as pd 
import json as json
import numpy as np 
from google.cloud import bigquery
from google.cloud import storage
from google.cloud.bigquery import SchemaField
import os

def rick_and_morty():
 
    # episodes table
    
    episode_df = pd.DataFrame()
    for i in range(1,4):
        url = 'https://rickandmortyapi.com/api/episode?page=' + str(i)
        rm = requests.get(url)
        for episode in rm.json()['results']:
            episode_df = episode_df.append({
                'id': episode['id'],
                'name': episode['name'],
                'air_date': episode['air_date'],
                'episode': episode['episode']
            }, ignore_index=True)
        
    client = bigquery.Client()
    episode_dataset_id = 'rick_and_morty'
    episode_table_id = 'episodes'

    episode_dataset_ref = client.dataset(episode_dataset_id)
    episode_table_id = episode_dataset_ref.table(episode_table_id)
    
    job_config = bigquery.LoadJobConfig()
    job_config.write_disposition='WRITE_TRUNCATE'
    job_config.source_format = bigquery.SourceFormat.CSV
    job_config.autodetect=True
    job_config.ignore_unknown_values=True 

    job = client.load_table_from_dataframe(
    episode_df,
    episode_table_id,
    location='US',
    job_config=job_config)

    job.result()
    print('The episodes table has updated.')
    
    # locations table
    
    locations_df = pd.DataFrame()
    for i in range(1,8):
        url = 'https://rickandmortyapi.com/api/location?page=' + str(i)
        rm = requests.get(url)
        for location in rm.json()['results']:
            locations_df = locations_df.append({
                'id': location['id'],
                'name': location['name'],
                'type': location['type'],
                'dimension': location['dimension']
            }, ignore_index=True)
        locations_df['dimension'] = locations_df['dimension'].str.title()
    
    client = bigquery.Client()
    locations_dataset_id = 'rick_and_morty'
    locations_table_id = 'locations'

    locations_dataset_ref = client.dataset(locations_dataset_id)
    locations_table_id = locations_dataset_ref.table(locations_table_id)
    
    job_config = bigquery.LoadJobConfig()
    job_config.write_disposition='WRITE_TRUNCATE'
    job_config.source_format = bigquery.SourceFormat.CSV
    job_config.autodetect=True
    job_config.ignore_unknown_values=True 

    job = client.load_table_from_dataframe(
    locations_df,
    locations_table_id,
    location='US',
    job_config=job_config)

    job.result()
    print('The locations table has updated.')
    
    # characters table 
    
    characters_df = pd.DataFrame()
    for i in range(1,43):
        url = 'https://rickandmortyapi.com/api/character/?page=' + str(i)
        rm = requests.get(url)
        for char in rm.json()['results']:
            characters_df = characters_df.append({
            'id': char['id'],
            'name': char['name'],
            'status': char['status'],
            'species': char['species'],
            'gender': char['gender']
        }, ignore_index=True)
    #return df 
    characters_df['status'] = characters_df['status'].str.title()
    
    client = bigquery.Client()
    characters_dataset_id = 'rick_and_morty'
    characters_table_id = 'characters'

    characters_dataset_ref = client.dataset(characters_dataset_id)
    characters_table_id = characters_dataset_ref.table(characters_table_id)
    
    job_config = bigquery.LoadJobConfig()
    job_config.write_disposition='WRITE_TRUNCATE'
    job_config.source_format = bigquery.SourceFormat.CSV
    job_config.autodetect=True
    job_config.ignore_unknown_values=True 

    job = client.load_table_from_dataframe(
    characters_df,
    characters_table_id,
    location='US',
    job_config=job_config)

    job.result()
    
    print('The characters table has updated.')
    
    return print('Rick and Morty has loaded.')

 if __name__ == "__main__":
  rick_and_morty()
