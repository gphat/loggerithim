CREATE SEQUENCE thresholds_thresholdid_seq;
CREATE TABLE thresholds (
	thresholdid	BIGINT CONSTRAINT pk_thresholds
		NOT NULL PRIMARY KEY DEFAULT nextval('thresholds_thresholdid_seq'),
	hostid		BIGINT NOT NULL REFERENCES hosts,
	resourceid	BIGINT NOT NULL REFERENCES resources,
	severity	SMALLINT NOT NULL,
	value		BIGINT NOT NULL,
	key			VARCHAR(255)
);
GRANT ALL ON thresholds_thresholdid_seq TO loggerithim;
GRANT ALL ON thresholds TO loggerithim;
