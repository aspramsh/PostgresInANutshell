--Full text search
DROP VIEW IF EXISTS membership.pending_users;
DROP TABLE IF EXISTS membership.users;
DROP SCHEMA IF EXISTS membership;
CREATE SCHEMA membership;

CREATE OR REPLACE FUNCTION random_string(len int) RETURNS TEXT AS
$$
	SELECT SUBSTRING(md5(random()::TEXT), 0, len) AS RESULT;
$$ LANGUAGE SQL;

CREATE TABLE membership.users(
	id SERIAL PRIMARY KEY NOT NULL,
	user_ker VARCHAR(18) DEFAULT random_string(18),
	email VARCHAR(255) UNIQUE NOT NULL,
	first VARCHAR(50),
	last VARCHAR(50),
	created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
	status VARCHAR(10) NOT NULL DEFAULT 'pending',
	search_field TSVECTOR NOT NULL
);

CREATE TRIGGER users_search_update_refresh
BEFORE INSERT OR UPDATE ON membership.users
FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(search_field, 'pg_catalog.english', email, first, last);

INSERT INTO membership.users (email, first, last)
VALUES ('test@test.com', 'Jane', 'Smith');

CREATE VIEW membership.pending_users AS
SELECT * FROM membership.users
WHERE status = 'pending';

SELECT * FROM membership.users;

--Search by name
SELECT * FROM membership.users
WHERE search_field @@ to_tsquery('jane');

SELECT * FROM membership.users
WHERE search_field @@ to_tsquery('ja:*');

SELECT * FROM membership.users
WHERE search_field @@ to_tsquery('jane & smith');

SELECT * FROM membership.users
WHERE search_field @@ to_tsquery('jane & smith');

SELECT * FROM membership.users
WHERE to_tsvector(concat(email, ' ', first, ' ', last)) @@ to_tsquery('jane & smith');
