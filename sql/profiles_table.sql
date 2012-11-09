CREATE SEQUENCE profiles_profileid_seq;
CREATE TABLE profiles (
	profileid	BIGINT CONSTRAINT pk_profiles
		NOT NULL PRIMARY KEY DEFAULT nextval('profiles_profileid_seq'), 
	name		VARCHAR(50) NOT NULL UNIQUE
);
GRANT ALL ON profiles_profileid_seq TO loggerithim;
GRANT ALL ON profiles TO loggerithim;

INSERT INTO profiles (name) VALUES ('None');
INSERT INTO profiles (name) VALUES ('Linux');
INSERT INTO profiles (name) VALUES ('Solaris');
