CREATE SEQUENCE smeeplets_smeepletid_seq;
CREATE TABLE smeeplets (
	smeepletid 	BIGINT CONSTRAINT pk_smeeplet
		NOT NULL PRIMARY KEY DEFAULT nextval('smeeplets_smeepletid_seq'),
	name 		VARCHAR(50) NOT NULL UNIQUE,
	description VARCHAR(255),
	detach		INT
);
GRANT ALL ON smeeplets_smeepletid_seq TO loggerithim;
GRANT ALL ON smeeplets TO loggerithim;
INSERT INTO smeeplets (name, description) VALUES (
	'FileSystemSpace', 'Filesystem Monitor');
INSERT INTO smeeplets (name, description) VALUES (
	'LastUpdated', 'Find Hosts that may not be responding');
