-- Get all Austin traffic crime data for 2008 - 2016 

WITH two_k_eight AS (
SELECT
  p_key
, date    
, crime_type 
, time
, address 
, location 
FROM 
(
    SELECT  
    SAFE_CAST(unique_key AS STRING) AS p_key
    , date AS date 
    , INITCAP(descript) AS crime_type
    , time 
    , INITCAP(address) AS address 
    , longitude AS long 
    , latitude AS lat 
    , REPLACE(REPLACE(location, ')', ' '),'(', ' ') AS location
    FROM `bigquery-public-data.austin_incidents.incidents_2008`
)),
two_k_nine AS (
    SELECT 
    p_key 
  , date 
  , crime_type 
  , time
  , address 
  , location 
    FROM 
    (
        SELECT 
        SAFE_CAST(unique_key AS STRING) AS p_key 
        , date AS date 
        , INITCAP(descript) AS crime_type
        , time 
        , INITCAP(address) AS address 
        , longitude AS long 
        , latitude AS lat 
        , REPLACE(REPLACE(location, ')', ' '), '(', ' ') AS location
        FROM `bigquery-public-data.austin_incidents.incidents_2009`
    )),
two_k_ten AS (
    SELECT 
    p_key 
  , date 
  , crime_type 
  , time
  , address 
  , location
    FROM (
    SELECT 
        SAFE_CAST(unique_key AS STRING) AS p_key
        , date AS date  
        , INITCAP(descript) AS crime_type
        , time 
        , INITCAP(address) AS address 
        , longitude AS long 
        , latitude AS lat 
        , REPLACE(REPLACE(location, ')', ' '), '(', ' ') AS location
    FROM `bigquery-public-data.austin_incidents.incidents_2010`
)),
two_k_eleven AS (
    SELECT 
    p_key 
  , date
  , crime_type 
  , time
  , address 
  , location 
    FROM 
    (
    SELECT 
        SAFE_CAST(unique_key AS STRING) AS p_key 
        , date AS date 
        , INITCAP(descript) AS crime_type
        , time 
        , INITCAP(address) AS address 
        , longitude AS long 
        , latitude AS lat 
        , REPLACE(REPLACE(location, ')', ' '), '(', ' ') AS location
        FROM `bigquery-public-data.austin_incidents.incidents_2011`
 )), 
two_k_sixteen AS (
    SELECT 
    p_key 
  , date 
  , crime_type 
  , time
  , address 
  , location 
    FROM 
    (
        SELECT 
        SAFE_CAST(unique_key AS STRING) AS p_key 
        , date AS date 
        , INITCAP(descript) AS crime_type
        , time 
        , INITCAP(address) AS address 
        , longitude AS long 
        , latitude AS lat 
        , REPLACE(REPLACE(location, ')', ' '), '(', ' ') AS location
        FROM `bigquery-public-data.austin_incidents.incidents_2016`
    )) 

SELECT *
FROM (
SELECT * FROM two_k_eight 
  UNION ALL 
  SELECT * FROM two_k_nine 
  UNION ALL 
  SELECT * FROM two_k_ten 
  UNION ALL 
  SELECT * FROM two_k_eleven 
  UNION ALL 
  SELECT * FROM two_k_sixteen
) a 
WHERE location IS NOT NULL 
AND crime_type IN ('Dwi', 'Crash/Leaving The Scene',
'Custody Arrest Traffic Warr', 'Driving While License Invalid', 
'Abandonded Veh', 'Out of City Auto Theft', 'Crash/Fail Stop And Render Aid',
'Dwi .15 Bac Or Above', 'Pedestrian On Roadway', 'Auto Theft', 'Burglary Of Vehicle',
'Auto Theft Information', 'Reckless Driving', 'Dwi - Drug Recognition Expert',
'Driving While Intox / Felony', 'Dwi Suspended Mandatory', 'Traffic Viol/Other',
'Crash/No Injury', 'Road Rage', 'Theft From Auto')
ORDER BY date DESC 
