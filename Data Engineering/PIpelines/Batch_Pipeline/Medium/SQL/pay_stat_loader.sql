INSERT INTO `****.medium.pay_stat`
(
WITH
  pay_stat AS (
  SELECT
    stat.title,
    stat.upvotes,
    stat.views,
    stat.reads,
    SAFE_CAST(stat.createdAt AS DATE) AS createdAt,
    SAFE_CAST(stat.firstPublishedAt AS DATE) AS firstPublishedAt,
    stat.firstPublishedAtBucket,
    SAFE_CAST(stat.readingTime AS FLOAT64) AS readingTime,
    stat.syndicatedViews,
    stat.claps,
    stat.internalReferrerViews,
    stat.previewImage_alt,
    stat.primaryTopic_name,
    SAFE_CAST(pay.latestRev AS STRING) AS latestRev,
    SAFE_CAST(pay.updatedAt AS DATE) AS updatedAt,
    SAFE_CAST(pay.latestPublishedAt AS DATE) AS latestPublishedAt,
    SAFE_CAST(pay.curationEligibleAt AS DATE) AS curationEligibleAt,
    pay.seoTitle,
    pay.isShortform,
    pay.isPublishToEmail,
    pay.isMarkedPaywallOnly,
    SAFE_CAST(pay.periodStartedAt AS DATE) AS periodStartedAt,
    SAFE_CAST(pay.periodEndedAt AS DATE) AS periodEndedAt,
    SAFE_CAST(pay.amount AS FLOAT64) / 100 AS amount,
    SAFE_CAST(pay.totalAmountPaidToDate AS FLOAT64) / 100 AS totalAmountPaidToDate
  FROM
    `****.medium.stats` stat
  LEFT JOIN
    `****.medium.pay` pay
  ON
    stat.postId = pay.id )
SELECT
  *
FROM
  pay_stat
)
