-- Get artist info for top 17th - 20th century American artists 
-- WITH block to select type of piece, artist's name, art medium, beginning date, end date, years an artist was active, the public domain status of a piece,
-- and an artist's job title. 
WITH artist_info AS (
    SELECT DISTINCT art_title
    , piece_type
    , artist_name
    , art_medium
    , art_begin_date
    , art_end_date
    , artist_career_in_years
    , is_public_domain
    , artist_job
     FROM 
-- Subquery to extract variables from innermost query. Notably, we're doing some column math to create a column detailing the years an artist was active.
-- This query also establishes a ranking partitioned by the object_id and aforementioned end date.
    (
    SELECT DISTINCT
      art_title
    , piece_type
    , artist_name
    , art_medium
    , art_begin_date
    , art_end_date
    , art_end_date - art_begin_date AS artist_career_in_years
    , is_public_domain
    , artist_job
    , date
    , RANK() OVER(PARTITION BY object_id ORDER BY art_end_date DESC) AS rank
-- Innermost query converts variable types with safe cast, producing nulls instead of throwing an error. Creates a date column. 
    FROM (
        SELECT SAFE_CAST(artist_begin_date AS INT64) AS art_begin_date,
        SAFE_CAST(artist_end_date AS INT64) AS art_end_date,
        SAFE_CAST(object_date AS INT64) AS obj_date,
        EXTRACT(DATE FROM metadata_date) AS date,
        object_id,
        is_public_domain,
-- Conditional logic to remove brackets surrounding prominent title entries. 
        CASE 
            WHEN title = '[Interborough Rapid Transit (IRT) Construction, 25th Street and Fourth Avenue, New York City]' THEN 
            SUBSTRING('[Interborough Rapid Transit (IRT) Construction, 25th Street and Fourth Avenue, New York City]',2, LENGTH('[Interborough Rapid Transit (IRT) Construction, 25th Street and Fourth Avenue, New York City]')-2)
            WHEN title = '[Man Cutting Watermelon]' THEN SUBSTRING('[Man Cutting Watermelon]', 2, LENGTH('[Man Cutting Watermelon]')-2)
            WHEN title = "[Migrant Pea Picker's Makeshift Home, Nipomo, California]" THEN SUBSTRING("[Migrant Pea Picker's Makeshift Home, Nipomo, California]", 2, LENGTH("[Migrant Pea Picker's Makeshift Home, Nipomo, California]")-2)
        ELSE title 
        END AS art_title,
        object_name AS piece_type,
        artist_display_name AS artist_name,
-- Conditional logic to create one-word medium names. 
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
        END AS art_medium,
-- Conditional logic to clarify artist roles. This statement ensures that each artist is only identified by one job title/role. 
        CASE 
            WHEN artist_role = 'Photography Studio' THEN 'Photographer'
            WHEN artist_role = 'Artist|Printer' THEN 'Printer'
            WHEN artist_role = 'Publisher|Artist' THEN 'Publisher'
            WHEN artist_role = 'Artist|Publisher' THEN 'Artist'
            WHEN artist_role = 'Former Attribution' THEN 'Contributor'
            WHEN artist_role = 'Maker|Maker' THEN 'Maker'
            WHEN artist_role = 'Artist and architect' THEN 'Architect'
            WHEN artist_role = 'Designer|Maker' THEN 'Designer'
            WHEN artist_role = 'Manufacturer|Inventor' THEN 'Inventor'
            WHEN artist_role = 'Former Attribution' THEN 'Collaborator'
            WHEN artist_role = 'Artist|Former Attribution' THEN 'Artist'
            WHEN artist_role = 'Manufacturer|Engraver' THEN 'Engraver'
            WHEN artist_role = 'Artist and publisher' THEN 'Publisher'
            WHEN artist_role = 'Author|Author' THEN 'Author'
            WHEN artist_role = 'Publisher|Printer' THEN 'Publisher'
            WHEN artist_role = 'Artist|Printer|Publisher' THEN 'Artist'
            WHEN artist_role = 'Publisher|Sitter' THEN 'Publisher'
            ELSE artist_role 
        END AS artist_job
        FROM `bigquery-public-data`.the_met.objects
        WHERE artist_nationality = 'American'
        AND artist_display_name NOT LIKE '%William B.%'
-- Filter for outliers that skew the artist career in years values. 
        AND artist_end_date NOT LIKE '%9999%'
    ))
-- Take the top results between the 17th and 20th centuries. Order by the date an artist started work. 
    WHERE rank = 1 
    AND art_begin_date BETWEEN 1600 AND 1900
    AND art_end_date BETWEEN 1600 AND 2000 
    ORDER BY art_begin_date DESC 
)
-- Select all 9 columns specified in the above WITH block to return 5911 rows out of 200,000 rows in original dataset.
SELECT * FROM
artist_info 
