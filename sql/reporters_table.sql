CREATE SEQUENCE reporters_reporterid_seq;
CREATE TABLE reporters (
	reporterid 	BIGINT CONSTRAINT pk_reporter
		NOT NULL PRIMARY KEY DEFAULT nextval('reporters_reporterid_seq'),
	name 		VARCHAR(50) NOT NULL UNIQUE,
	description VARCHAR(255)
);
GRANT ALL ON reporters_reporterid_seq TO loggerithim;
GRANT ALL ON reporters TO loggerithim;
