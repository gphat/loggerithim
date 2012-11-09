CREATE SEQUENCE attributes_attributeid_seq;
CREATE TABLE attributes (
	attributeid	BIGINT CONSTRAINT pk_attributes
		NOT NULL PRIMARY KEY DEFAULT nextval('attributes_attributeid_seq'),
	name		VARCHAR(50) NOT NULL UNIQUE,
	sigil		VARCHAR(50),
	types		VARCHAR(255),
	hours		SMALLINT,
	macros		VARCHAR(255),
	url			TEXT
);
GRANT ALL ON attributes_attributeid_seq TO loggerithim;
GRANT ALL ON attributes TO loggerithim;

INSERT INTO attributes (name) VALUES ('None');
INSERT INTO attributes (name) VALUES ('Default');
INSERT INTO attributes (name, sigil, types, hours, macros) VALUES ('CPU', 'CPU', 'cpuIdle,cpuUser,cpuSys', 24, 'charttype=filled&max=100');
INSERT INTO attributes (name, sigil, types, hours) VALUES ('Linux Memory', 'Memory', 'memAvailReal,memBuffered,memCached', 24);
INSERT INTO attributes (name, sigil, types, hours) VALUES ('Solaris Memory', 'Memory', 'memAvailReal', 24);
INSERT INTO attributes (name, sigil, types, hours) VALUES ('Load', 'Load', 'loaLoad1,loaLoad2,loaLoad3', 24);
INSERT INTO attributes (name, sigil, types, hours) VALUES ('Swap', 'Swap', 'memAvailSwap', 24);
