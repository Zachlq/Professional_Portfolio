WITH mascot AS (
    SELECT * FROM 
    (
        SELECT 
         id
        ,name
        ,mascot
        ,mascot_name
        ,mascot_common_name
        FROM `bigquery-public-data.ncaa_basketball.mascots`
    )WHERE mascot!='None'
     AND mascot_name IS NOT NULL
     AND mascot_common_name IS NOT NULL 
),
color AS (
    SELECT * FROM (
        SELECT 
        market 
        , id 
        , color 
        FROM
        `bigquery-public-data.ncaa_basketball.team_colors`
    )
), 
team AS (
    SELECT * FROM
    (
        SELECT 
        id
        ,conf_alias
        ,venue_capacity
         FROM 
        `bigquery-public-data.ncaa_basketball.mbb_teams`
    )
    PIVOT
    (
        AVG(venue_capacity) AS avg_cap
        FOR conf_alias IN ('IVY', 'BIG12', 'BIG10', 'HORIZON', 'BIGEAST', 'BIGWEST', 'COLONIAL', 'SOUTHERN',
                          'SUNBELT', 'BIGSOUTH', 'NE', 'SOUTHLAND', 'PAC12', 'WCC', 'A10', 'OVC', 'AS',
                          'WAC', 'AAC', 'MEAC', 'SWAC', 'MAAC')

))

SELECT DISTINCT * EXCEPT(id) FROM mascot
LEFT JOIN color ON mascot.id = color.id
LEFT JOIN team ON team.id = mascot.id
