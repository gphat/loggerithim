CREATE SEQUENCE metrics_metricid_seq;
CREATE TABLE metrics (	
	metricid	BIGINT CONSTRAINT pk_metricid
		NOT NULL PRIMARY KEY DEFAULT nextval('metrics_metricid_seq'),
	resgroupid	BIGINT NOT NULL REFERENCES resgroups, 
	hostid		BIGINT NOT NULL REFERENCES hosts,
	data		TEXT NOT NULL, 
	timestamp	TIMESTAMP NOT NULL
);
CREATE INDEX metrics_timestamp_index ON metrics (timestamp);
GRANT ALL ON metrics_metricid_seq TO loggerithim;
GRANT ALL on metrics TO loggerithim;
