CREATE SEQUENCE profattrs_profattrid_seq;
CREATE TABLE profattrs (
	profattrid	BIGINT CONSTRAINT pk_profattrs
		NOT NULL PRIMARY KEY DEFAULT nextval('profattrs_profattrid_seq'), 
	profileid	BIGINT NOT NULL REFERENCES profiles,
	attributeid	BIGINT NOT NULL REFERENCES attributes
);
GRANT ALL ON profattrs_profattrid_seq TO loggerithim;
GRANT ALL ON profattrs TO loggerithim;

INSERT INTO profattrs (profileid, attributeid) VALUES (2, 2);
INSERT INTO profattrs (profileid, attributeid) VALUES (2, 3);
INSERT INTO profattrs (profileid, attributeid) VALUES (2, 5);
INSERT INTO profattrs (profileid, attributeid) VALUES (2, 6);

INSERT INTO profattrs (profileid, attributeid) VALUES (3, 2);
INSERT INTO profattrs (profileid, attributeid) VALUES (3, 4);
INSERT INTO profattrs (profileid, attributeid) VALUES (3, 5);
INSERT INTO profattrs (profileid, attributeid) VALUES (3, 6);
