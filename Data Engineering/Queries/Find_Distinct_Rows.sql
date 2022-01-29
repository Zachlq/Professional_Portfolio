SELECT
  * EXCEPT(max_timestamp)
FROM (
  SELECT
    date,
    user,
    sales,
    last_updated_on,
    MAX(last_updated_on) OVER(PARTITION BY date) AS max_timestamp
  FROM
    `ornate-reef-332816.sales.totals` )
WHERE
  last_updated_on = max_timestamp
ORDER BY
  date DESC
