# Medium

A pipeline that syncs data from the (unofficial) Medium API into my BigQuery project. From BigQuery I dashboard insights in Looker Studio. 
In Looker I schedule daily emails that contain the report contents. 

Data from [the Medium API](https://docs.mediumapi.com/) is associated with my [Medium profile](https://medium.com/@zachl-quinn). While Medium's dashboard allows Medium Partners to track 
views, reads and claps within a 30-day rolling window, the Medium UI lacks granularity when it comes to viewing and accessing data for day-over-day changes.
Medium typically sends a weekly report of stats via email. However, as a writer, I'd like to have access to both historic and real-time data on a daily basis.
So, using a stack familiar to me, GCP+Python+SQL+Looker, I created a tool to generate custom reports that are sent to my email on a daily basis.

To get the data for every story I pass a unique ID assigned to the story at publish time and accessible in the UI at the end of a URL string.

As a writer and editor on Medium I've realized that metrics like views and reads are not the most helpful dimensions when it comes to tracking user engagement.
Therefore, my report includes the following metrics:

- Total claps (Medium's equivalent of "liking" a story)
- Total fans (the number of accounts that "clapped")
- Clap to fan ratio (since users have the ability to clap up to 50 times for 1 story claps can be disproportionate to fans)
- Milestones (when a story reaches 10, 50 or 100 fans)
- Engagement (a value derived from a proprietary combo of the above and other metrics)
- Reading time (Medium's estimate of how long it will take to read a story)
- Responses count (how many responses or comments a story receives)
- Is Boosted (Medium's "boost" program promotes stories that meet certain criteria)

Additionally, since the Medium API is a paid service I keep a log of my script runs, which I explain in [this story](https://medium.com/pipeline-a-data-engineering-resource/track-api-usage-in-your-python-script-not-your-credit-card-bill-151248a7f873).

I'm in the process of deploying the Python script in this directory as a pub/sub-triggered cloud function through GCP.

The total report is between 1-5 pages and a screenshot of one of the less granular reports is included below.

![Screen Shot 2023-06-19 at 2 51 46 PM](https://github.com/Zachlq/Professional_Portfolio/assets/58344148/5d4557bb-2111-4b8d-9d16-287cdeb788d4)
