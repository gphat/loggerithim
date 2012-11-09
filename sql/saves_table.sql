CREATE SEQUENCE saves_saveid_seq;
CREATE TABLE saves (
	saveid	BIGINT CONSTRAINT pk_saveid
		NOT NULL PRIMARY KEY DEFAULT nextval('saves_saveid_seq'),
	userid	BIGINT NOT NULL REFERENCES users,
	page	VARCHAR(50) NOT NULL,
	params	TEXT NOT NULL,
	name	VARCHAR(50) NOT NULL
);
GRANT ALL on saves_saveid_seq TO loggerithim;
GRANT ALL on saves TO loggerithim;
