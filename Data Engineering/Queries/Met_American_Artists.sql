-- Get artist info for 17th & 20th century American artists from Google Big Query's The Met dataset 
WITH artist_info AS (
    SELECT art_title
    , piece_type
    , artist_name
    , art_medium
    , art_begin_date
    , art_end_date
    , obj_date
    , obj_begin_date
    , obj_end_date
     FROM 
    (
    SELECT 
      art_title
    , piece_type
    , artist_name
    , art_medium
    , art_begin_date
    , art_end_date 
    , obj_date 
    , obj_begin_date
    , obj_end_date
    , date
    , RANK() OVER(PARTITION BY object_id ORDER BY obj_end_date DESC) AS rank
    FROM (
        SELECT SAFE_CAST(artist_begin_date AS INT64) AS art_begin_date,
        SAFE_CAST(artist_end_date AS INT64) AS art_end_date,
        SAFE_CAST(object_date AS INT64) AS obj_date,
        SAFE_CAST(object_begin_date AS INT64) AS obj_begin_date,
        SAFE_CAST(object_end_date AS INT64) AS obj_end_date,
        SAFE_CAST(object_number AS INT64) AS obj_number,
        EXTRACT(DATE FROM metadata_date) AS date,
        object_id,
        title AS art_title,
        object_name AS piece_type,
        artist_display_name AS artist_name,
        CASE 
            WHEN medium = 'Platinum print' THEN 'Photo'
            WHEN medium = 'Leather, beads' THEN 'Leather'
            WHEN medium = 'Oil on canvas' THEN 'Oil Painting'
            WHEN medium = 'Gouache and graphite on paper' THEN 'Gouache'
            WHEN medium = 'Gouache on paper' THEN 'Gouache'
            WHEN medium = 'Lithograph, edition 9/75' THEN 'Lithograph'
            WHEN medium = 'Lithograph, edition 24/100' THEN 'Lithograph'
            WHEN medium = 'silver' THEN 'Silver'
            WHEN medium = 'Granite, and cast aluminum, on concrete plinth' THEN 'Granite Sculpture'
            WHEN medium = 'Silver point drawing on paper' THEN 'Silver'
            WHEN medium = 'Graphite on cardboard' THEN 'Pencil Sketch'
            WHEN medium = 'Ink and graphite on mat board' THEN 'Ink'
            WHEN medium = 'Gelatin silver print' THEN 'Silver Print'
            WHEN medium = 'Silver, pearls' THEN 'Silver'
            WHEN medium = 'Ink on cardstock' THEN 'Ink'
            WHEN medium = 'Commercial relief process' THEN 'Etching'
            WHEN medium = 'Oil on Masonite' THEN 'Oil Painting'
            WHEN medium = 'Oil on composition board' THEN 'Oil Painting'
            WHEN medium = 'Charcoal on paper' THEN 'Charcoal'
            WHEN medium = 'Pastel, charcoal, ink, and wash on paper' THEN 'Pastel'
            WHEN medium = 'Ink, pastel and charcoal on paper' THEN 'Ink'
            WHEN medium = 'Oil on canvas board' THEN 'Oil Painting'
            WHEN medium = 'Oil on canvas, adhered to cardboard' THEN 'Oil Painting'
            WHEN medium = 'Watercolor, graphite and cut-and-pasted paper on paper' THEN 'Watercolor'
            WHEN medium = 'Watercolor on paper' THEN 'Watercolor'
            WHEN medium = 'Watercolor and graphite on paper' THEN 'Pencil'
            WHEN medium = 'Crayon on paper' THEN 'Crayon'
            WHEN medium = 'Conte and chalk on paper' THEN 'Chalk'
        ELSE medium 
        END AS art_medium
        FROM `bigquery-public-data`.the_met.objects
        WHERE artist_nationality = 'American'
    ))
    WHERE rank = 1 
    AND art_begin_date BETWEEN 1600 AND 1900
    AND obj_date IS NOT NULL 
    ORDER BY art_begin_date DESC 
)

SELECT *
FROM artist_info
