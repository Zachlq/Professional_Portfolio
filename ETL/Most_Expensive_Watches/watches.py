import pandas as pd
from pandas import read_html
import numpy as np
from google.cloud import bigquery
import os
from google.cloud.bigquery import SchemaField

def get_watches():
    
    # Numbers 1 - 77
    
    base_url = 'https://en.wikipedia.org/wiki/List_of_most_expensive_watches_sold_at_auction'
    watches = read_html(base_url, attrs={'class': 'wikitable sortable'}, header=1)
    watch_df = pd.DataFrame(watches[0])
    watch_df.rename(columns={'.mw-parser-output .tooltip-dotted{border-bottom:1px dotted;cursor:help}M.Y.': 'Model_Year', 'Watch model': 'Watch_Model',
                             'Inflation-adjusted': 'Inflation_Adjusted',
                        'Auctiondate': 'Auction_Date', 'Auctionplace': 'Auction_Place', 'Auctionhouse': 'Auction_House'}, inplace=True)
    watch_df = watch_df.drop(['Ref.'], axis=1)

    for col in watch_df.columns:
        watch_df['Watch_Model'] = watch_df['Watch_Model'].str.replace('[Note 4]', '')
        watch_df['Watch_Model'] = watch_df['Watch_Model'].str.replace(r'\[.*\]', ' ')
    
    watch_df['Auction_Date'] = pd.to_datetime(watch_df['Auction_Date'])
    
    # Numbers 77 - 113
    
    watch_second_half = watches[1]
    watch_second_half_df = pd.DataFrame(watch_second_half)

    watch_second_half_df.rename(columns={'Watch model': 'Watch_Model', 'M.Y.': 'Model_Year', 'Inflation-adjusted': 'Inflation_Adjusted',
                                 'Auctiondate': 'Auction_Date', 'Auctionplace': 'Auction_Place', 'Auctionhouse': 'Auction_House'}, inplace=True)
    watch_second_half_df = watch_second_half_df.drop(['Ref.'], axis=1)
    
    watch_second_half_df['Auction_Date'] = pd.to_datetime(watch_second_half_df['Auction_Date'])
    
    # Latest Auction Prices
    
    watch_third_url = 'https://en.wikipedia.org/wiki/List_of_most_expensive_watches_sold_at_auction'
    watch_third = pd.read_html(watch_third_url, attrs={'class': 'wikitable sortable'})
    watch_third_df = pd.DataFrame(watch_third[2])
    watch_third_df = watch_third_df.drop(['Adjusted price (USD millions)'], axis=1)
    watch_third_df = watch_third_df.drop(['Ref.'], axis=1)
    watch_third_df.rename(columns={'Watch model': 'Watch_Model', 'M.Y.': 'Model_Year', 'Original price (USD millions)':
                          'Price_USD_Millions', 'Auction date': 'Auction_Date', 'Auction place': 'Auction_Place',
                          'Auction house': 'Auction_House'}, inplace=True)
    
    for col in watch_third_df.columns:
        watch_third_df['Price_USD_Millions'] = watch_third_df['Price_USD_Millions'].str.replace("(without buyer's premium)", '')
        
    for col in watch_third_df.columns:
        watch_third_df['Price_USD_Millions'] = watch_third_df['Price_USD_Millions'].str.replace(r"\(.*\)", '')
    
    for col in watch_third_df.columns:
        watch_third_df['Model_Year'] = watch_third_df['Model_Year'].str.replace(r'\[.*\]', '1951')
        watch_third_df['Model_Year'] = watch_third_df['Model_Year'].str.replace(r"\(.*\)", '')
    
    watch_third_df['Auction_Date'] = pd.to_datetime(watch_third_df['Auction_Date'])
    
    watch_third_df['Price_USD_Millions'] = watch_third_df['Price_USD_Millions'].astype(float)
    
    watch_all = pd.concat([watch_df, watch_second_half_df, watch_third_df], ignore_index=True)
    watch_all = watch_all.sort_values(by=['Manufacturer'], ascending=True).reset_index(drop=True)
    watch_all['Original'] = watch_all['Original'].fillna(0)
    watch_all['Inflation_Adjusted'] = watch_all['Inflation_Adjusted'].fillna(0)
    watch_all['Price_USD_Millions'] = watch_all['Price_USD_Millions'].fillna(0)
    
    watch_all_df = pd.DataFrame(watch_all)
    
    schema = [
        bigquery.SchemaField("Rank", "INTEGER", mode="NULLABLE"),
        bigquery.SchemaField("Manufacturer", "STRING", mode="NULLABLE"),
        bigquery.SchemaField("Model_Year", "STRING", mode="NULLABLE"),
        bigquery.SchemaField("Style", "STRING", mode="NULLABLE"),
        bigquery.SchemaField("Original", "FLOAT", mode="NULLABLE"),
        bigquery.SchemaField("Inflation_Adjusted", "FLOAT", mode="NULLABLE"),
        bigquery.SchemaField("Auction_Date", "TIMESTAMP", mode="NULLABLE"),
        bigquery.SchemaField("Auction_Place", "STRING", mode="NULLABLE"),
        bigquery.SchemaField("Auction_House", "STRING", mode="NULLABLE"),
        bigquery.SchemaField("Price_USD_Millions", "FLOAT", mode="NULLABLE")
    ]
    
    client = bigquery.Client()
    dataset_id = 'watches'
    table_id = 'auction_prices'
    
    dataset_ref = client.dataset(dataset_id)
    table_id = dataset_ref.table(table_id)
    
    job_config = bigquery.LoadJobConfig()
    job_config.write_disposition='WRITE_TRUNCATE'
    job_config.source_format = bigquery.SourceFormat.CSV
    job_config.schema = schema
    job_config.autodetect=True
    job_config.ignore_unknown_values=True 

    job = client.load_table_from_dataframe(
    watch_all_df,
    table_id,
    location='US',
    job_config=job_config)
    
    job.result()
    
    return print('The auction_prices table has been updated')
    
if __name__ == "__main__":
  get_watches()
