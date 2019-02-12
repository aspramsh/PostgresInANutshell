CREATE TABLE events (
    uuid text,
    name text,
    user_id bigint,
    account_id bigint,
    created_at timestamptz
);

CREATE TABLE events_20190212 ( 
    CHECK (created_at >= '2019-02-12 00:00:00' AND created_at < '2019-02-13 00:00:00')  
) INHERITS (events);

CREATE TABLE events_20190213 ( 
    CHECK (created_at >= '2019-02-13 00:00:00' AND created_at < '2019-02-14 00:00:00')   
) INHERITS (events);

CREATE OR REPLACE FUNCTION event_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF ( NEW.created_at >= '2019-02-12 00:00:00' AND
         NEW.created_at < '2019-02-13 00:00:00' ) THEN
        INSERT INTO events_20190212 VALUES (NEW.*);
    ELSIF ( NEW.created_at >= '2019-02-13 00:00:00'AND
         NEW.created_at < '2019-02-14 00:00:00' ) THEN
        INSERT INTO events_20190213 VALUES (NEW.*);
    ELSE
        RAISE EXCEPTION 'Date out of range.  Fix the event_insert_trigger() function!';
    END IF;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_event_trigger
    BEFORE INSERT ON events
    FOR EACH ROW EXECUTE PROCEDURE event_insert_trigger();