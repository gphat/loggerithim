CREATE SEQUENCE hostattr_hostattrid_seq;
CREATE TABLE hostattrs (
	hostattrid	BIGINT CONSTRAINT pk_hostattrs
		NOT NULL PRIMARY KEY DEFAULT nextval('hostattr_hostattrid_seq'),
	hostid		BIGINT NOT NULL REFERENCES hosts,
	attributeid	BIGINT NOT NULL REFERENCES attributes
);
GRANT ALL ON hostattr_hostattrid_seq TO loggerithim;
GRANT ALL ON hostattrs TO loggerithim;
