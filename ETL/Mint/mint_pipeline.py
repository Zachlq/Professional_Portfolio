import pandas as pd 
import os 
import pydata_google_auth
from google.oauth2 import service_account
from google.cloud import language
import json 
from google.cloud import storage 
from google.cloud import bigquery
import mintapi as mintapi
import selenium
from selenium import webdriver 
import pydata_google_auth

schema = [
    {
        "name": "type",
        "type": "STRING",
        "mode": "NULLABLE"},
    {
        "name": "investmentTransactionType",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "quantity",
        "type": "FLOAT",
        "mode": "NULLABLE"
    },
    {
        "name": "id",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "accountId",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "accountRef",
        "type": "RECORD",
        "mode": "REPEATED",
        "fields": [
            {
                "name": "id",
                "type": "STRING",
                "mode": "NULLABLE"
            },
            {
                "name": "name",
                "type": "STRING",
                "mode": "NULLABLE"
            },
            {
                "name": "type",
                "type": "STRING",
                "mode": "NULLABLE"
            },
            {
                "name": "hiddenFromPlanningAndTrends",
                "type": "BOOLEAN",
                "mode": "NULLABLE"
            }
        ]
    },
    {
        "name": "date",
        "type": "DATE",
        "mode": "NULLABLE"
    },
    {
        "name": "description",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "category",
        "type": "RECORD",
        "mode": "REPEATED",
        "fields": [
            {
                "name": "id",
                "type": "STRING",
                "mode": "NULLABLE"
            },
            {
                "name": "name",
                "type": "STRING",
                "mode": "NULLABLE"
            },
            {
                "name": "categoryType",
                "type": "STRING",
                "mode": "NULLABLE"
            },
            {
                "name": "parentId",
                "type": "STRING",
                "mode": "NULLABLE"
            },
            {
                "name": "parentName",
                "type": "STRING",
                "mode": "NULLABLE"
            }
        ]
    },
    {
        "name": "amount",
        "type": "FLOAT",
        "mode": "NULLABLE"
    },
    {
        "name": "currency",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "status",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "matchState",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "fiData",
        "type": "RECORD",
        "mode": "REPEATED",
        "fields": [
            {
                "name": "date",
                "type": "DATE",
                "mode": "NULLABLE"
            },
            {
                "name": "amount",
                "type": "FLOAT",
                "mode": "NULLABLE"
            },
            {
                "name": "description",
                "type": "STRING",
                "mode": "NULLABLE"
            },
            {
                "name": "inferredDescription",
                "type": "STRING",
                "mode": "NULLABLE"
            },
            {
                "name": "inferredCategory",
                "type": "RECORD",
                "mode": "REPEATED",
                "fields": [
                    {
                        "name": "id",
                        "type": "STRING",
                        "mode": "NULLABLE"
                    },
                    {
                        "name": "name",
                        "type": "STRING",
                        "mode": "NULLABLE"
                    }
                ]
            },
            {
                "name": "id",
                "type": "STRING",
                "mode": "NULLABLE"
            }
        ]
    },
    {
        "name": "isReviewed",
        "type": "BOOLEAN",
        "mode": "NULLABLE"
    },
    {
        "name": "transactionType",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "etag",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "isExpense",
        "type": "BOOLEAN",
        "mode": "NULLABLE"
    },
    {
        "name": "isPending",
        "type": "BOOLEAN",
        "mode": "NULLABLE"
    },
    {
        "name": "discretionaryType",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "isLinkedToRule",
        "type": "BOOLEAN",
        "mode": "NULLABLE"
    },
    {
        "name": "transactionReviewState",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "lastUpdatedDate",
        "type": "TIMESTAMP",
        "mode": "NULLABLE"
    },
    {
        "name": "merchantId",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "principalCurrency",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "interestCurrency",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "escrowCurrency",
        "type": "STRING",
        "mode": "NULLABLE"
    }
    
]

bucket_name = "mint_info"
bucket = storage.Client().get_bucket(bucket_name)

def upload_to_bq(df):
    
    client = bigquery.Client()
    dataset_id = 'mint'
    table_id = 'spending_raw'

    dataset_ref = client.dataset(dataset_id)
    table_ref = dataset_ref.table(table_id)

    job_config = bigquery.LoadJobConfig()
    job_config.write_disposition='WRITE_TRUNCATE'
    job_config.source_format = bigquery.SourceFormat.NEWLINE_DELIMITED_JSON
    job_config.schema = schema
    job_config.ignore_unknown_values=True 

    job = client.load_table_from_json(
    df,
    table_ref,
    location='US',
    job_config=job_config)
    
    return job.result()
        
def get_mint_transactions():
    
    mint_auth = mintapi.Mint(
    mfa_method = None,
    mfa_input_callback=None,
    mfa_token=None,
    intuit_account=None,
    headless=False,
    session_path=None,
    imap_account=None,
    imap_password=None,
    imap_server=None,
    imap_folder='INBOX',
    wait_for_sync=False, 
    wait_for_sync_timeout=300,
    use_chromedriver_on_path=False
    )
    
    mint = mint_auth.get_transaction_data(include_investment=True)
    mint_auth.close()
    
    df = pd.DataFrame(mint)
    
    return df 

def main():
    
    df = get_mint_transactions()
    
    mint_data = df.to_json("mint_output.json", orient="records")
    
    with open("mint_output.json") as f:
        mint_data = json.load(f)
    
    blob = bucket.blob("mint_output.json")
    
    blob.upload_from_string(data=json.dumps(mint_data), content_type="application/json")
    
    blob = bucket.get_blob("mint_output.json")
    
    mint_data_blob = json.loads(blob.download_as_string())
    
    upload_to_bq(mint_data_blob)

if __name__ == "__main__":
  main()
