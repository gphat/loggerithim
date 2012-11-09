CREATE SEQUENCE events_eventid_seq;
CREATE TABLE events (
	eventid		BIGINT CONSTRAINT pk_events
		NOT NULL PRIMARY KEY DEFAULT nextval('events_eventid_seq'),
	hostid		BIGINT REFERENCES hosts,
	jobid		BIGINT REFERENCES jobs,
	severity	SMALLINT NOT NULL,
	identifier	VARCHAR(100) NOT NULL,
	message		TEXT NOT NULL,
	timestamp	TIMESTAMP NOT NULL,
	attempts	INTEGER,
	squelched	SMALLINT,
	hushed		SMALLINT
);
GRANT ALL ON events_eventid_seq TO loggerithim;
GRANT ALL ON events TO loggerithim;
