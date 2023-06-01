# A Rickin' Pipeline

![r_m_title_card](https://github.com/Zachlq/Professional_Portfolio/assets/58344148/bf841928-b2b8-4e35-9d20-111e0e4b4f53)

_Rick and Morty logo courtesy of Wikipedia. Rick and Morty are the intellectual property of Adult Swim and this usage is for educational and demonstration purposes only._

Aside from being a fun departure from the "typical" data a pipeline would be ingest, this Rick and Morty-inspired pipeline demonstrates an important concept for data engineers -- how to retrieve data stored in multiple different URLs, a concept which I discuss in [this blog post](https://medium.com/pipeline-a-data-engineering-resource/how-to-use-python-to-access-data-in-multiple-urls-with-rick-and-morty-6d0d3d502cb5)

The data comes from the free and open source [Rick and Morty API](https://rickandmortyapi.com/). The API is GQL-based and provides a handful of end points to retrieve data about the Adult Swim series, including character lists, episode summaries and story locations. 

My ingestion process is a standard ETL pipeline, fetching data from the API and eventually pushing to a dataset hosted in my personal BigQuery project.

The goal is to use some "fun" data to demonstrate the importance of dynamic retrieval and ensuring that a pipeline scrapes ALL available data.
