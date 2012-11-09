CREATE SEQUENCE custom_metrics_metricid_seq;
CREATE TABLE custom_metrics (	
	metricid	BIGINT CONSTRAINT pk_metricid
		NOT NULL PRIMARY KEY DEFAULT nextval('custom_metrics_metricid_seq'),
	hostid		BIGINT NOT NULL REFERENCES hosts,
	type		BIGINT NOT NULL, 
	data		TEXT NOT NULL, 
	timestamp	TIMESTAMP NOT NULL
);
GRANT ALL ON custom_metrics_metricid_seq TO loggerithim;
GRANT ALL on custom_metrics TO loggerithim;
