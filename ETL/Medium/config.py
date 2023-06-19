from datetime import datetime

today = datetime.today().strftime("%Y-%m-%d")

creds = "/Users/zachquinn/Downloads/ornate-reef-332816-a7425b762ba2.json"

scope = ["https://www.googleapis.com/auth/spreadsheets", "https://www.googleapis.com/auth/drive"]

sheet_url = "https://docs.google.com/spreadsheets/d/1OOkCvd63xI1l75f2zx57vcqOeDDzQSpKHgBW96QsGbg/edit#gid=0"

bucket = "medium_info"
file = "med_creds.json"

bools = ['is_locked', 'is_series']

dataset = "medium"

table = "article_stats"

log_table = "medium_log"

medium_schema = [
    {
        "name": "id",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "tags",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "claps",
        "type": "INTEGER",
        "mode": "NULLABLE"
    },
    {
        "name": "last_modified_at",
        "type": "TIMESTAMP",
        "mode": "NULLABLE"
    },
    {
        "name": "published_at",
        "type": "TIMESTAMP",
        "mode": "NULLABLE"
    },
    {
        "name": "url",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "image_url",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "is_series",
        "type": "BOOLEAN",
        "mode": "NULLABLE"
    },
    {
        "name": "lang",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "publication_id",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "word_count",
        "type": "INTEGER",
        "mode": "NULLABLE"
    },
    {
        "name": "is_locked",
        "type": "BOOLEAN",
        "mode": "NULLABLE"
    },
    {
        "name": "title",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "reading_time",
        "type": "FLOAT",
        "mode": "NULLABLE"
    },
    {
        "name": "responses_count",
        "type": "INTEGER",
        "mode": "NULLABLE"
    },
    {
        "name": "voters",
        "type": "INTEGER",
        "mode": "NULLABLE"
    },
    {
        "name": "topics",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "author",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "subtitle",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "dt_updated",
        "type": "DATETIME",
        "mode": "NULLABLE"
    }
]

log_schema = [
    {
        "name": "requests",
        "type": "INTEGER",
        "mode": "NULLABLE"
    },
    {
        "name": "success",
        "type": "BOOLEAN",
        "mode": "NULLABLE"
    },
    {
        "name": "run_time",
        "type": "FLOAT",
        "mode": "NULLABLE"
    },
    {
        "name": "updated_time",
        "type": "TIMESTAMP",
        "mode": "NULLABLE"
    }
]
