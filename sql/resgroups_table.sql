CREATE SEQUENCE resgroups_resgroupid_seq;
CREATE TABLE resgroups (
	resgroupid	BIGINT CONSTRAINT pk_resgroups
		NOT NULL PRIMARY KEY DEFAULT nextval('resgroups_resgroupid_seq'),
	name		VARCHAR(30) NOT NULL UNIQUE,
	custom		SMALLINT NOT NULL,
	keyed		SMALLINT NOT NULL
);
GRANT ALL ON resgroups_resgroupid_seq TO loggerithim;
GRANT ALL ON resgroups TO loggerithim;
INSERT INTO resgroups(name, custom, keyed) VALUES ('memory', 0, 0);
INSERT INTO resgroups(name, custom, keyed) VALUES ('cpu', 0, 0);
INSERT INTO resgroups(name, custom, keyed) VALUES ('misc', 0, 0);
INSERT INTO resgroups(name, custom, keyed) VALUES ('load', 0, 0);
INSERT INTO resgroups(name, custom, keyed) VALUES ('interfaces', 0, 1);
INSERT INTO resgroups(name, custom, keyed) VALUES ('static', 0, 0);
INSERT INTO resgroups(name, custom, keyed) VALUES ('storage', 0, 1);
INSERT INTO resgroups(name, custom, keyed) VALUES ('rawcpu', 0, 0);
INSERT INTO resgroups(name, custom, keyed) VALUES ('rawinterfaces', 0, 1);
INSERT INTO resgroups(name, custom, keyed) VALUES ('rawmisc', 0, 0);
