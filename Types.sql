--Date, Timestamp
--Postgres
SELECT to_char('2001-02-03'::DATE, 'FMDay DD Mon YYYY');  --this produces the string "Saturday 03 Feb 2001";
SELECT to_timestamp('Saturday 03 Feb 2001', 'FMDay DD Mon YYYY');  --this produces the timestamp value 2001-02-03 00:00:00+00;

--INTERVAL type
SELECT
 now(),
 now() - INTERVAL '1 year 3 hours 20 minutes' 
             AS "3 hours 20 minutes ago of last year";

--MsSQL
SELECT CONVERT(datetime, '2001-02-03T12:34:56.789', 126);  --this produces the datetime value 2001-02-03 12:34:56:789

--Array example
-- create a table where the values are arrays
CREATE TABLE holiday_picnic (  
     holiday varchar(50), -- single value
     sandwich text[], -- array
     side text[] [], -- multi-dimensional array
     dessert text ARRAY, -- array
     beverage text ARRAY[4] -- array of 4 items
);

 -- insert array values into the table
INSERT INTO holiday_picnic VALUES  
     ('Labor Day',
     '{"roast beef","veggie","turkey"}',
     '{
        {"potato salad","green salad","macaroni salad"},
        {"chips","crackers", "cheese"}
     }',
     '{"fruit cocktail","berry pie","ice cream"}',
     '{"soda","juice","beer","water"}'
     );

--Hstore
CREATE EXTENSION hstore;

CREATE TABLE books (
 id serial primary key,
 title VARCHAR (255),
 attr hstore
);

INSERT INTO books (title, attr)
VALUES
 (
 'PostgreSQL Tutorial',
 '"paperback" => "243",
    "publisher" => "postgresqltutorial.com",
    "language"  => "English",
    "ISBN-13"   => "978-1449370000",
 "weight"    => "11.2 ounces"'
 ),
 (
 'PostgreSQL Cheat Sheet',
 '
"paperback" => "5",
"publisher" => "postgresqltutorial.com",
"language"  => "English",
"ISBN-13"   => "978-1449370001",
"weight"    => "1 ounces"'
 );

SELECT attr -> 'publisher' AS publisher
FROM books;

SELECT attr -> 'weight' AS weight
FROM books
WHERE
 attr -> 'ISBN-13' = '978-1449370000';

 --check for a specific key
SELECT title, attr->'publisher' as publisher, attr
FROM books
WHERE attr ? 'publisher';

--ENUMS
CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy');
CREATE TABLE person (
    name text,
    current_mood mood
);
INSERT INTO person VALUES ('Moe', 'happy');
SELECT * FROM person WHERE current_mood = 'happy';

--Geometric types
-- create a table for trails
CREATE TABLE trails (  
     trail_name varchar(250),
     trail_path path
);

--Domains
CREATE TABLE mail_list (
    ID SERIAL PRIMARY KEY,
    first_name VARCHAR NOT NULL,
    last_name VARCHAR NOT NULL,
    email VARCHAR NOT NULL,
    CHECK (
        first_name !~ '\s'
        AND last_name !~ '\s'
    )
);

CREATE DOMAIN contact_name AS 
    VARCHAR NOT NULL CHECK (value !~ '\s');
	
CREATE TABLE mail_list (
    id serial PRIMARY KEY,
    first_name contact_name,
    last_name contact_name,
    email VARCHAR NOT NULL
);

 -- insert a trail into the table
 -- where the path is defined by lat-long coordinates
INSERT INTO trails VALUES  
     ('Dool Trail - Creeping Forest Trail Loop',
     ('(37.172, -122.22261666667),
     (37.171616666667, -122.22385),
     (37.1735, -122.2236),
     (37.175416666667, -122.223),
     (37.1758, -122.22378333333),
     (37.179466666667, -122.22866666667),
     (37.18395, -122.22675),
     (37.180783333333, -122.22466666667),
     (37.176116666667, -122.2222),
     (37.1753, -122.22293333333),
     (37.173116666667, -122.22281666667)'));

--user created type
-- create a new composite type called "wine"
CREATE TYPE wine AS (  
     wine_vineyard varchar(50),
     wine_type varchar(50),
     wine_year int
);

 -- create a table that uses the composite type "wine"
CREATE TABLE pairings (  
     menu_entree varchar(50),
     wine_pairing wine
);

 -- insert data into the table using the ROW expression
INSERT INTO pairings VALUES  
     ('Lobster Tail',ROW('Stag''s Leap','Chardonnay', 2012)),
     ('Elk Medallions',ROW('Rombauer','Cabernet Sauvignon',2012));

 /*
   query from the table using the table column name
   (use parentheses followed by a period
   then the name of the field from the composite type)
 */
SELECT (wine_pairing).wine_vineyard, (wine_pairing).wine_type  
FROM pairings  
WHERE menu_entree = 'Elk Medallions';  

--NoSQl aka JSONB
SELECT row_to_json(film)։։JSONB 
FROM film;

INSERT INTO film_docs(data)
SELECT row_to_json(film)։։JSONB 
FROM film;

--Demonstrate from here
SELECT * 
FROM film_docs;

SELECT (data -> 'title') AS title,
(data -> 'length') AS length
FROM film_docs;

SELECT (data ->> 'title') AS title,
(data -> 'length') AS length
FROM film_docs
WHERE (data ->> 'title') = 'Chamber Italian';

SELECT (data ->> 'title') AS title,
(data -> 'length') AS length
FROM film_docs
WHERE data -> 'title' ? 'Chamber Italian';

SELECT (data ->> 'title') AS title,
(data -> 'length') AS length
FROM film_docs
WHERE data @> '{"title": "Chamber Italian"}';

CREATE INDEX ON film_docs USING GIN(data);

EXPLAIN ANALYZE SELECT (data ->> 'title') AS title,
(data -> 'length') AS length
FROM film_docs
WHERE data @> '{"title": "Chamber Italian"}';
