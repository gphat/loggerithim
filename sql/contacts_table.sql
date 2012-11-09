CREATE SEQUENCE contacts_contactid_seq;
CREATE TABLE contacts (
	contactid	BIGINT CONSTRAINT pk_contacts
		NOT NULL PRIMARY KEY DEFAULT nextval('contacts_contactid_seq'),
	userid		BIGINT NOT NULL REFERENCES users,
	mediumid	BIGINT NOT NULL REFERENCES mediums,
	value		VARCHAR(30) NOT NULL
);
GRANT ALL ON contacts_contactid_seq TO loggerithim;
GRANT ALL ON contacts TO loggerithim;
