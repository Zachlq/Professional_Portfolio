import pandas as pd 
import requests
import numpy as np 
import matplotlib.pyplot as plt
import re
import json
from datetime import datetime
from google.cloud import bigquery
import os 

def get_stats():
    medium_text = open('stats.txt', 'r', encoding='utf-8').read()
    med_df=pd.DataFrame(json.loads(re.sub(r'^.*?{', '{', medium_text)))
    med_stories = pd.json_normalize(med_df.loc['value', 'payload'], sep = '_')

    cols = ['firstPublishedAt', 'createdAt']
    
    for col in cols:
        med_stories[col] = pd.to_datetime(med_stories[col], unit='ms')
        med_stories[col] = med_stories[col].dt.strftime('%Y-%m-%d')
    
    del_cols = ['primaryTopic_visibility', 'primaryTopic_relatedTags', 
                'primaryTopic_relatedTopicIds', 'primaryTopic_seoTitle', 'primaryTopic_type', 'primaryTopic_relatedTopics',
               'primaryTopic_image_id', 'slug', 'primaryTopic_topicId', 'primaryTopic_createdAt',
               'primaryTopic_deletedAt', 'previewImage_isFeatured', 'type', 'previewImage_id',
               'previewImage_originalWidth', 'previewImage_originalHeight',
               'primaryTopic_image_originalWidth', 'primaryTopic_image_originalHeight',
               'primaryTopic_description']
    
    for col in del_cols:
        del med_stories[col]
    
    pd.set_option('display.max_columns', None)
    med_stories = pd.DataFrame(med_stories)
    return med_stories

def get_paid():
    payment_text = open('pay_stats.txt', 'r', encoding='utf-8').read()
    pay_df=pd.DataFrame(json.loads(re.sub(r'^.*?{', '{', payment_text)))
    post_amount_df = pd.DataFrame(pay_df['payload']['postAmounts'])
    paid = pd.concat([post_amount_df.post.apply(pd.Series), post_amount_df.drop('post', axis=1)], axis=1)
    
    paid_del_cols = [
     'detectedLanguage',
     'latestVersion',
     'latestPublishedVersion',
     'hasUnpublishedEdits',
     'acceptedAt',
     'slug',
     'experimentalCss',
     'displayAuthor',
     'virtuals',
     'coverless',
     'editorialPreviewTitle',
     'shortformType',
     'weeklyAmounts',
     'translationSourcePostId',
     'translationSourceCreatorId',
     'isApprovedTranslation',
     'inResponseToPostId',
     'inResponseToRemovedAt',
     'isTitleSynthesized',
     'allowResponses',
     'importedUrl',
     'importedPublishedAt',
     'visibility',
     'uniqueSlug',
     'previewContent',
     'license',
     'inResponseToMediaResourceId',
     'canonicalUrl',
     'approvedHomeCollectionId',
     'isNewsletter',
     'newsletterId',
     'webCanonicalUrl',
     'mediumUrl',
     'migrationId',
     'notifyFollowers',
     'notifyTwitter',
     'notifyFacebook',
     'responseHiddenOnParentPostAt',
     'isSeries',
     'isSubscriptionLocked',
     'seriesLastAppendedAt',
     'audioVersionDurationSec',
     'sequenceId',
     'isEligibleForRevenue',
     'isBlockedFromHightower',
     'deletedAt',
     'lockedPostSource',
     'hightowerMinimumGuaranteeStartsAt',
     'hightowerMinimumGuaranteeEndsAt',
     'featureLockRequestAcceptedAt',
     'mongerRequestType',
     'layerCake',
     'socialTitle',
     'socialDek',
     'editorialPreviewDek',
     'isProxyPost',
     'proxyPostFaviconUrl',
     'proxyPostProviderName',
     'proxyPostType',
     'isSuspended',
     'isLimitedState',
     'previewContent2',
     'cardType',
     'isDistributionAlertDismissed',
     'responsesLocked',
     'isLockedResponse',
     'responseDistribution',
     'createdAt',
     'type',
     'userId',
     'totalAmountInCents']
    
    for col in paid_del_cols:
        del paid[col]
    
    dt_cols = ['updatedAt', 'firstPublishedAt', 'latestPublishedAt', 'periodStartedAt', 'periodEndedAt', 'curationEligibleAt']
    
    for cols in dt_cols:
        paid[cols] = pd.to_datetime(paid[cols], unit='ms')
        paid[cols] = paid[cols].dt.strftime('%Y-%m-%d')
    
    return paid 
    
    def upload_to_bq(table_id, df): 
      
        client = bigquery.Client()

        dataset_id = 'medium'
        table_id = table_id 

        dataset_ref = client.dataset(dataset_id)
        table_id = dataset_ref.table(table_id)

        job_config = bigquery.LoadJobConfig()
        job_config.write_disposition='WRITE_TRUNCATE'
        job_config.source_format = bigquery.SourceFormat.CSV
        job_config.ignore_unknown_values=True 

        job = client.load_table_from_dataframe(
        df,
        table_id,
        location='US',
        job_config=job_config)

        job.result()

def main():
    med_stories = get_stats()
    paid = get_paid()
    upload_to_bq('stats', med_stories)
    upload_to_bq('pay', paid)
    return 'Success!'

if __name__ == "__main__":
    main()
