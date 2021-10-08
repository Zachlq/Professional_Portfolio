WITH mask AS (
    SELECT * EXCEPT(rank) FROM (
    SELECT *
    , RANK() OVER(PARTITION BY county_fips_code ORDER BY pct_always DESC) AS rank
    FROM 
    (
        SELECT 
        county_fips_code
        ,ROUND(never*100,2) AS pct_never 
        ,ROUND(rarely*100,2) AS pct_rarely
        ,ROUND(sometimes*100,2) AS pct_sometimes
        ,ROUND(frequently*100,2) AS pct_frequent
        ,ROUND(always*100,2) AS pct_always
        FROM 
        `bigquery-public-data.covid19_nyt.mask_use_by_county`
    )

)   WHERE rank=1) SELECT * FROM mask

us_county AS (
    SELECT *
    FROM (
        SELECT date 
        , county 
        , CASE
             WHEN state_name = 'Alabama' THEN 'AL'
             WHEN state_name = 'Alaska' THEN 'AK'
             WHEN state_name = 'Arkansas' THEN 'AR'
             WHEN state_name = 'Arizona' THEN 'AZ'
             WHEN state_name = 'California' THEN 'CA'
             WHEN state_name = 'Colorado' THEN 'CO'
             WHEN state_name = 'Connecticut' THEN 'CT'
             WHEN state_name = 'Delaware' THEN 'DE'
             WHEN state_name = 'Florida' THEN 'FL'
             WHEN state_name = 'Georgia' THEN 'GA'
             WHEN state_name = 'Hawaii' THEN 'HI'
             WHEN state_name = 'Idaho' THEN 'ID'
             WHEN state_name = 'Illinois' THEN 'IL'
             WHEN state_name = 'Indiana' THEN 'IN'
             WHEN state_name = 'Iowa' THEN 'IA'
             WHEN state_name = 'Kansas' THEN 'KS'
             WHEN state_name = 'Kentucky' THEN 'KY'
             WHEN state_name = 'Louisiana' THEN 'LA'
             WHEN state_name = 'Maine' THEN 'ME'
             WHEN state_name = 'Maryland' THEN 'MD'
             WHEN state_name = 'Massachusetts' THEN 'MA'
             WHEN state_name = 'Michigan' THEN 'MI'
             WHEN state_name = 'Minnesota' THEN 'MN'
             WHEN state_name = 'Mississippi' THEN 'MS'
             WHEN state_name = 'Missouri' THEN 'MO'
             WHEN state_name = 'Montana' THEN 'MT'
             WHEN state_name = 'Nebraska' THEN 'NE'
             WHEN state_name = 'Nevada' THEN 'NV'
             WHEN state_name = 'New Hampshire' THEN 'NH'
             WHEN state_name = 'New Jersey' THEN 'NJ'
             WHEN state_name = 'New Mexico' THEN 'NM'
             WHEN state_name = 'New York' THEN 'NY'
             WHEN state_name = 'North Carolina' THEN 'NC'
             WHEN state_name = 'North Dakota' THEN 'ND'
             WHEN state_name = 'Ohio' THEN 'OH'
             WHEN state_name = 'Oklahoma' THEN 'OK'
             WHEN state_name = 'Oregon' THEN 'OR'
             WHEN state_name = 'Pennsylvania' THEN 'PA'
             WHEN state_name = 'Rhode Island' THEN 'RI'
             WHEN state_name = 'South Carolina' THEN 'SC'
             WHEN state_name = 'South Dakota' THEN 'SD'
             WHEN state_name = 'Tennesseee' THEN 'TN'
             WHEN state_name = 'Texas' THEN 'TX'
             WHEN state_name = 'Utah' THEN 'UT'
             WHEN state_name = 'Vermont' THEN 'VT'
             WHEN state_name = 'Virginia' THEN 'VA'
             WHEN state_name = 'Washington' THEN 'WA'
             WHEN state_name = 'West Virginia' THEN 'WV'
             WHEN state_name = 'Wisconsin' THEN 'WI'
             WHEN state_name = 'Wyoming' THEN 'WY'
        ELSE state_name END AS state_abbrv 
        , county_fips_code 
        , confirmed_cases
        , deaths 
        FROM 
        `bigquery-public-data.covid19_nyt.us_counties`
        WHERE date >= DATE_SUB(CURRENT_DATE(), date, INTERVAL 1 YEAR)
    )
) SELECT state_name FROM us_county 


SELECT * EXCEPT(county_fips_code)
FROM mask 
JOIN us_county 
ON mask.county_fips_code = us_county.county_fips_code 
