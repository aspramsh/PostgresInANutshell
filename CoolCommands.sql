--Get supported index types
SELECT * 
	FROM pg_am;

--Fill users table with random data
INSERT INTO public.users(
	first_name, last_name)
		SELECT md5(random()::text), md5(random()::text) FROM
          (SELECT * FROM generate_series(1,1000000) AS id) AS x;