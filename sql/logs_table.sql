CREATE SEQUENCE logs_logid_seq;
CREATE TABLE logs (
	logid		BIGINT CONSTRAINT pk_logs
		NOT NULL PRIMARY KEY DEFAULT nextval('logs_logid_seq'),
	timestamp	TIMESTAMP NOT NULL,
	severity	VARCHAR(25) NOT NULL,
	package		VARCHAR(255),
	line		VARCHAR(10),
	message		TEXT NOT NULL
);
GRANT ALL ON logs_logid_seq TO loggerithim;
GRANT ALL ON logs TO loggerithim;
