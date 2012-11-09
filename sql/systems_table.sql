CREATE SEQUENCE systems_systemid_seq;
CREATE TABLE systems (
	systemid BIGINT CONSTRAINT pk_system
		NOT NULL PRIMARY KEY DEFAULT nextval('systems_systemid_seq'),
	name        VARCHAR(50) NOT NULL UNIQUE
);
GRANT ALL ON systems_systemid_seq TO loggerithim;
GRANT ALL ON systems TO loggerithim;
