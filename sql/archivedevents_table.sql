CREATE SEQUENCE archivedevents_eventid_seq;
CREATE TABLE archivedevents (
	eventid		BIGINT CONSTRAINT pk_archivedevents
		NOT NULL PRIMARY KEY,
	parentid	BIGINT,
	hostid		BIGINT REFERENCES hosts,
	severity	SMALLINT NOT NULL,
	identifier	VARCHAR(100),
	message		TEXT NOT NULL,
	timestamp	TIMESTAMP NOT NULL
);
GRANT ALL ON archivedevents_eventid_seq TO loggerithim;
GRANT ALL on archivedevents TO loggerithim;
