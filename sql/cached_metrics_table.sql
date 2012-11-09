CREATE SEQUENCE cached_metrics_metricid_seq;
CREATE TABLE cached_metrics (
	metricid	BIGINT CONSTRAINT pk_cached_metrics
		NOT NULL PRIMARY KEY DEFAULT nextval('cached_metrics_metricid_seq'),
	hostid		BIGINT NOT NULL REFERENCES hosts,
	resgroupid	BIGINT NOT NULL REFERENCES resgroups,
	data		TEXT NOT NULL,
	timestamp	TIMESTAMP NOT NULL
);
GRANT ALL ON cached_metrics_metricid_seq TO loggerithim;
GRANT ALL ON cached_metrics TO loggerithim;
