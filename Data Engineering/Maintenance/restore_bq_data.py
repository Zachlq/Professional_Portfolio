import time 
import logging
from google.cloud import bigquery
import os

def restore_bq_data():
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"]="/Users/zachquinn/Downloads/ornate-reef-332816-a7425b762ba2.json"
    
    client = bigquery.Client()
    
    table_id = 'ornate-reef-332816.xmas.tree_test'
    recovered_table_id = 'ornate-reef-332816.xmas.tree_recovery'
    
    snapshot_epoch = int(time.time() * 1000)
    
    #unix = datetime.datetime(2022, 1, 12, 0, 0).strftime('%s')
    #unix_int = int(unix)
    #unix_ms = unix_int * 1000
    
    #past_snap = unix_ms
    
    client.delete_table(table_id)
    
    snapshot_table_id = "{}@{}".format(table_id, snapshot_epoch)
    
    job = client.copy_table(
        snapshot_table_id,
        recovered_table_id,
        location="US"
    )
    
    success = "The table restoration was successful."
    if job.result():
        print(
        "Restored data from deleted table {} to {}".format(table_id, recovered_table_id)
        )
        logging.info(f'The job result was: {success}')
    
    failure = "The table restoration was unsuccessful."
    if not job.result():
        print(failure)
        logging.info(f'The job result was: {failure}')
    
restore_bq_data()
