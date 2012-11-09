CREATE SEQUENCE childevents_childeventid_seq;
CREATE TABLE childevents (
	childeventid	BIGINT CONSTRAINT pk_childevents
		NOT NULL PRIMARY KEY DEFAULT nextval('childevents_childeventid_seq'),
	eventid		BIGINT NOT NULL REFERENCES events,
	severity	BIGINT NOT NULL,
	message		TEXT NOT NULL,
	timestamp	TIMESTAMP NOT NULL
);
GRANT ALL ON childevents_childeventid_seq TO loggerithim;
GRANT ALL ON childevents TO loggerithim;
