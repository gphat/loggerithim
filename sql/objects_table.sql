CREATE SEQUENCE objects_objectid_seq;
CREATE TABLE objects (
	objectid	BIGINT CONSTRAINT pk_objectid
		NOT NULL PRIMARY KEY DEFAULT nextval('objects_objectid_seq'),
	name		VARCHAR(50) NOT NULL UNIQUE
);
GRANT ALL on objects_objectid_seq TO loggerithim;
GRANT ALL on objects TO loggerithim;

INSERT INTO objects (name) VALUES ('Annotation');
INSERT INTO objects (name) VALUES ('Attribute');
INSERT INTO objects (name) VALUES ('Contact');
INSERT INTO objects (name) VALUES ('Department');
INSERT INTO objects (name) VALUES ('Event');
INSERT INTO objects (name) VALUES ('Group');
INSERT INTO objects (name) VALUES ('Host');
INSERT INTO objects (name) VALUES ('Job');
INSERT INTO objects (name) VALUES ('Notification');
INSERT INTO objects (name) VALUES ('Object');
INSERT INTO objects (name) VALUES ('Profile');
INSERT INTO objects (name) VALUES ('Report');
INSERT INTO objects (name) VALUES ('Reporter');
INSERT INTO objects (name) VALUES ('ResourceGroup');
INSERT INTO objects (name) VALUES ('Resource');
INSERT INTO objects (name) VALUES ('Smeeplet');
INSERT INTO objects (name) VALUES ('System');
INSERT INTO objects (name) VALUES ('Threshold');
INSERT INTO objects (name) VALUES ('User');
