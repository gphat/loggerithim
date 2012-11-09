CREATE SEQUENCE mediums_mediumid_seq;
CREATE TABLE mediums (
	mediumid	BIGINT CONSTRAINT pk_mediums
		NOT NULL PRIMARY KEY DEFAULT nextval('mediums_mediumid_seq'),
	name		VARCHAR(20) UNIQUE NOT NULL,
	handler		VARCHAR(100) NOT NULL
);
GRANT ALL ON mediums_mediumid_seq TO loggerithim;
GRANT ALL ON mediums TO loggerithim;

INSERT INTO mediums (name, handler) VALUES ('email', 'Loggerithim::Medium::email');
INSERT INTO mediums (name, handler) VALUES ('email mobile', 'Loggerithim::Medium::email');
