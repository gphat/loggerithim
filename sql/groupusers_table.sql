CREATE SEQUENCE groupusers_groupuserid_seq;
CREATE TABLE groupusers (
	groupuserid	BIGINT CONSTRAINT pk_groupuserid
		NOT NULL PRIMARY KEY DEFAULT nextval('groupusers_groupuserid_seq'),
	groupid		BIGINT NOT NULL REFERENCES groups,
	userid		BIGINT NOT NULL REFERENCES users
);
GRANT ALL on groupusers_groupuserid_seq TO loggerithim;
GRANT ALL on groupusers TO loggerithim;
