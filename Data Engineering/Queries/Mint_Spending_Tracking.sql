SELECT
  amount_spent,
  day_beginning,
  amount_remaining,
  monthly_income_percent_spent,
  CASE
    WHEN money_advice = 0 THEN 'Save that next paycheck!'
  ELSE
  'Available spending money!'
END
  AS money_advice
FROM (
  SELECT
    amount_spent,
    day_beginning,
    amount_remaining,
    monthly_income_percent_spent,
    CASE
      WHEN monthly_income_percent_spent >= 50.0 THEN 0
    ELSE
    1
  END
    AS money_advice
  FROM (
    SELECT
      amount_spent,
      day_beginning,
      amount_remaining,
      ROUND(SAFE_DIVIDE(amount_spent,
          4000), 2) * 100 AS monthly_income_percent_spent
    FROM (
      SELECT
        amount_spent,
        day_beginning,
        4000 - amount_spent AS amount_remaining
      FROM (
        SELECT
          ROUND(SUM(amount),2) AS amount_spent,
          DATE_SUB(CURRENT_DATE('America/New_York'), INTERVAL 11 DAY) AS day_beginning
        FROM (
          SELECT
            EXTRACT(DATE
            FROM
              date) AS date,
            amount,
            category
          FROM
            `ornate-reef-332816.mint.transactions`
          WHERE
            amount NOT IN(500.0,
              1000.0,
              300.0,
              375.0,
              557.06)
          GROUP BY
            date,
            amount,
            category
          ORDER BY
            date DESC )
        WHERE
          date >= DATE_SUB(CURRENT_DATE(), INTERVAL 11 DAY) ) )))
