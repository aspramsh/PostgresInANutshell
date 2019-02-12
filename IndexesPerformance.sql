--B-Tree Select rows without index on payment_date and with index
--Compare execution time
EXPLAIN ANALYZE SELECT * 
	FROM payment 
	WHERE payment_date < '01-05-2007';

--Hash index
--Here we get an error, because the string is too long
CREATE INDEX idx_t_hash_1 ON t_hash USING btree (info);
CREATE INDEX idx_t_hash_1 ON t_hash USING hash (info);

SET enable_seqscan = OFF;
EXPLAIN ANALYZE SELECT * FROM t_hash WHERE info = (SELECT info FROM t_hash LIMIT 1); 

--GIN index
--Compare performance
EXPLAIN ANALYZE SELECT count(*) 
	FROM users 
	where first_name ilike '%aeb%';

EXPLAIN ANALYZE SELECT count(*) 
	FROM users 
	where first_name ilike '%aeb%' 
	or last_name ilike'%aeb%';

--Create GIN index combining 2 text columns 
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX users_search_idx ON users USING gin (first_name gin_trgm_ops, last_name gin_trgm_ops);

--GiST Versus B-Tree for ltree data structure
CREATE EXTENSION ltree;

CREATE UNIQUE INDEX dmoz_id_idx ON dmoz (id);
CREATE INDEX dmoz_path_idx ON dmoz USING gist (path);

--We can do inheritance
EXPLAIN ANALYZE SELECT path FROM dmoz WHERE path < 'Top.Adult';

--Full text search
SELECT path FROM test WHERE path @ 'Astro*% & !pictures@';

--SP-GiST
CREATE INDEX idx_t_spgist_1 ON t_spgist USING spgist (rg);

EXPLAIN ANALYZE SELECT * FROM t_spgist WHERE rg && int4range(1,100);

--BRIN 
--1st example
CREATE TABLE temperature_log (log_id serial, sensor_id int, log_timestamp timestamp without time zone, temperature int);

--This will create 31536001 rows of sensor test data.
INSERT INTO temperature_log(sensor_id,log_timestamp,temperature) VALUES (1,generate_series('2019-01-01'::timestamp,'2019-12-31'::timestamp,'1 second'),
round(random()*100)::int);

--Parallel sequential scan
EXPLAIN ANALYZE SELECT AVG(temperature) FROM temperature_log WHERE log_timestamp>='2019-04-04' AND log_timestamp<'2019-04-05';

--Create b-tree
CREATE INDEX idx_temperature_log_log_timestamp ON temperature_log USING btree (log_timestamp);

--Create BRIN
DROP INDEX idx_temperature_log_log_timestamp;

CREATE INDEX idx_temperature_log_log_timestamp ON temperature_log USING BRIN (log_timestamp) WITH (pages_per_range = 128);

--return index sizes
SELECT
nspname AS schema_name,
relname AS index_name,
round(100 * pg_relation_size(indexrelid) / pg_relation_size(indrelid)) / 100 AS index_ratio,
pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
pg_size_pretty(pg_relation_size(indrelid)) AS table_size

FROM
pg_index I

LEFT JOIN
pg_class C

ON
(C.oid = I.indexrelid)

LEFT JOIN
pg_namespace N

ON
(N.oid = C.relnamespace)

WHERE
C.relkind = 'i' AND
pg_relation_size(indrelid) > 0 AND
relname='idx_temperature_log_log_timestamp'

ORDER BY
pg_relation_size(indexrelid) DESC, index_ratio DESC;


--2nd example
SELECT ctid, * FROM t_brin LIMIT 3;
SELECT correlation FROM pg_stats WHERE tablename='t_brin' AND attname='id';

CREATE INDEX idx_t_brin_1 ON t_brin USING brin (id) WITH (pages_per_range=1);
CREATE INDEX idx_t_brin_2 ON t_brin USING brin (crt_time) WITH (pages_per_range=1);

EXPLAIN ANALYZE SELECT * FROM t_brin WHERE id BETWEEN 100 AND 200;
EXPLAIN ANALYZE SELECT * FROM t_brin WHERE crt_time BETWEEN '2019-02-03 22:38:46.849869' AND '2019-02-03 22:38:46.851608'; --change dates
