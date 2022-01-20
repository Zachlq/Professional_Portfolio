WITH
  conversion_demo AS (
  SELECT
    "dataset_table_1" AS table_name,
    89014286 AS bytes
  UNION ALL
  SELECT
    'dataset_table_2' AS table_name,
    8032073052 AS bytes
  UNION ALL
  SELECT
    'dataset_table_3' AS table_name,
    111217526600000 AS bytes
  UNION ALL
  SELECT
    'dataset_table_4' AS table_name,
    6016202191 AS bytes
  UNION ALL
  SELECT
    'dataset_table_5' AS table_name,
    710316140000 AS bytes
  UNION ALL
  SELECT
    'dataset_table_6' AS table_name,
    24797946090000000 AS bytes
  UNION ALL
  SELECT
    'dataset_table_7' AS table_name,
    1589783887000 AS bytes
  UNION ALL
  SELECT
    'dataset_table_8' AS table_name,
    584322356 AS bytes
  UNION ALL
  SELECT
    'dataset_table_9' AS table_name,
    9266575761 AS bytes
  UNION ALL
  SELECT
    'dataset_table_10' AS table_name,
    35519854 AS bytes )
SELECT
  table_name,
  bits,
  bytes,
  kb,
  mb,
  gb,
  tb,
  pb
FROM (
  SELECT
    table_name,
    bytes,
    gb,
    tb,
    kb,
    mb,
    bits,
    ROUND(tb / 1000) AS pb
  FROM (
    SELECT
      table_name,
      bytes,
      gb,
      tb,
      kb,
      mb,
      ROUND(bytes / 8, 2) AS bits
    FROM (
      SELECT
        table_name,
        bytes,
        gb,
        tb,
        kb,
        ROUND(gb * 1000, 2) AS mb
      FROM (
        SELECT
          table_name,
          bytes,
          gb,
          tb,
          ROUND(gb * 1000000, 2) AS kb
        FROM (
          SELECT
            table_name,
            bytes,
            gb,
            ROUND(gb / 1000, 2) AS tb
          FROM (
            SELECT
              table_name,
              bytes,
              bytes / ROUND((1024 * 1024 * 1024),2) AS gb
            FROM (
              SELECT
                table_name,
                bytes
              FROM
                conversion_demo )))))))
