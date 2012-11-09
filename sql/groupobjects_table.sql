CREATE SEQUENCE groupobjects_groupobjectid_seq;
CREATE TABLE groupobjects (
	groupobjectid	BIGINT CONSTRAINT pk_groupobjectid
		NOT NULL PRIMARY KEY DEFAULT nextval('groupobjects_groupobjectid_seq'),
	groupid			BIGINT NOT NULL REFERENCES groups,
	objectid		BIGINT NOT NULL REFERENCES objects,
	read			NUMERIC(1,0) NOT NULL,
	write			NUMERIC(1,0) NOT NULL,
	remove			NUMERIC(1,0) NOT NULL
);
GRANT ALL on groupobjects_groupobjectid_seq TO loggerithim;
GRANT ALL on groupobjects TO loggerithim;
