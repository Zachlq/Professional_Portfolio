WITH chicago_domestic_crime 
AS (
SELECT 
  date
, block
, report_code
, crime_type
, crime_description
, location
, beat
, district
, ward 
, community_area
, fbi_code 
, year 
, years_since_update
, lat 
, long
FROM (
SELECT 
unique_key
, case_num 
, date
, block
, report_code
, crime_type
, CASE 
    WHEN crime_description = 'endangering life/health child' THEN 'child endangerment'
    WHEN crime_description = 'endangering life / health of child' THEN 'child endangerment'
    WHEN crime_description = 'agg crim sex abuse fam member' THEN 'abuse by family member'
    ELSE crime_description END AS crime_description
, CASE 
    WHEN location = 'hospital building / grounds' THEN 'hospital'
    WHEN location = 'residence - yard (front/back)' THEN 'residence'
    WHEN location = 'school, private, building' THEN 'private school'
    WHEN location = 'movie house / theater' THEN 'movie theater'
    WHEN location = 'other (specify)' THEN 'unspecified'
    WHEN location = 'parking lot/garage(non.resid.)' THEN 'parking garage'
    WHEN location = 'hotel/motel' THEN 'hotel'
    WHEN location = 'police facility / vehicle parking lot' THEN 'police station'
    WHEN location = 'parking lot / garage (non residential)' THEN 'parking lot'
    WHEN location = 'school, public, grounds' THEN 'public school'
    WHEN location = 'cha apartment' THEN 'apartment'
ELSE location END AS location
, arrest
, domestic_crime
, beat
, district
, ward
, community_area
, fbi_code
, year 
, update_date - year AS years_since_update
, lat 
, long
, RANK() OVER(PARTITION BY unique_key ORDER BY date DESC) AS rank 
FROM (
SELECT unique_key
, SAFE_CAST(case_number AS INT64) AS case_num
, EXTRACT(DATE FROM date) AS date
, LOWER(block) AS block
, SAFE_CAST(iucr AS INT64) AS report_code
, CASE
    WHEN primary_type = 'DECEPTIVE PRACTICE' THEN 'fraud'
    WHEN primary_type = 'OTHER OFFENSE' THEN 'unspecified crime'
    WHEN primary_type = 'CRIMINAL TRESSPASS' THEN 'tresspass'
    WHEN primary_type = 'MOTOR VEHICLE THEFT' THEN 'grand theft auto'
    WHEN primary_type = 'PUBLIC PEACE VIOLATION' THEN 'disturbing the peace'
    WHEN primary_type = 'OFFENSE INVOLVING CHILDREN' THEN 'child abuse'
    WHEN primary_type = 'CRIMINAL DAMAGE' THEN 'property damage'
    WHEN primary_type = 'ASSAULT' THEN 'assault'
    WHEN primary_type = 'BATTERY' THEN 'battery'
  ELSE primary_type END AS crime_type
, LOWER(description) AS crime_description
, LOWER(location_description) AS location
, CASE
    WHEN arrest = true THEN 1 ELSE 0 END AS arrest
, CASE
    WHEN domestic = true THEN 1 ELSE 0 END AS domestic_crime
, beat
, district 
, ward 
, community_area 
, fbi_code 
, year 
, EXTRACT(DATE FROM updated_on) AS update_date
, ROUND(latitude,2) AS lat
, ROUND(longitude,2) AS long 
FROM `bigquery-public-data.chicago_crime.crime`
WHERE domestic = true
AND arrest = true  
AND primary_type = 'OFFENSE INVOLVING CHILDREN'
AND year BETWEEN 2019 AND 2021
)
)
WHERE rank = 1
AND crime_type IN 
('child abuse', 
'tresspass', 
'assault', 'battery')
AND lat IS NOT NULL
AND long IS NOT NULL
ORDER BY date DESC) 

SELECT 
  date
, block
, report_code
, crime_type
, crime_description
, location
, beat
, district
, ward 
, community_area
, fbi_code 
, year 
, years_since_update
, lat 
, long
FROM 
chicago_domestic_crime 
