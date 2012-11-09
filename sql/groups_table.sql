CREATE SEQUENCE groups_groupid_seq;
CREATE TABLE groups (
	groupid			BIGINT CONSTRAINT pk_groupid
		NOT NULL PRIMARY KEY DEFAULT nextval('groups_groupid_seq'),
	departmentid	BIGINT REFERENCES departments,
	systemid		BIGINT REFERENCES systems,
	name			VARCHAR(50) NOT NULL UNIQUE
);
GRANT ALL on groups_groupid_seq TO loggerithim;
GRANT ALL on groups TO loggerithim;

INSERT INTO groups (name) VALUES ('Administrators');
INSERT INTO groups (name) VALUES ('Staff');
