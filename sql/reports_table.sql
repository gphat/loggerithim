CREATE SEQUENCE reports_reportid_seq;
CREATE TABLE reports (
	reportid	BIGINT CONSTRAINT pk_reportid
		NOT NULL PRIMARY KEY DEFAULT nextval('reports_reportid_seq'),
	reporterid	BIGINT NOT NULL REFERENCES reporters,
	attributeid BIGINT NOT NULL REFERENCES attributes,
	interval	VARCHAR(100) NOT NULL,
	output		VARCHAR(25) NOT NULL
);
GRANT ALL on reports_reportid_seq TO loggerithim;
GRANT ALL on reports TO loggerithim;
