CREATE SEQUENCE hosts_hostid_seq;
CREATE TABLE hosts (
	hostid			BIGINT CONSTRAINT pk_hosts
		NOT NULL PRIMARY KEY DEFAULT nextval('hosts_hostid_seq'),
	systemid		BIGINT NOT NULL REFERENCES systems,
	departmentid	BIGINT NOT NULL REFERENCES departments,
	name			VARCHAR(50) NOT NULL UNIQUE,
	ip				VARCHAR(20) NOT NULL UNIQUE,
	active			SMALLINT NOT NULL,
	purpose			VARCHAR(255) NOT NULL,
	db_sid			VARCHAR(50),
	db_port			INTEGER,
	db_password		VARCHAR(50),
	last_sampled	TIMESTAMP
);
GRANT ALL ON hosts_hostid_seq TO loggerithim;
GRANT ALL ON hosts TO loggerithim;
