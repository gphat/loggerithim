CREATE SEQUENCE annotations_annotationid_seq;
CREATE TABLE annotations (
	annotationid 	BIGINT CONSTRAINT pk_annotations
		NOT NULL PRIMARY KEY DEFAULT nextval('annotations_annotationid_seq'),
	systemid		BIGINT NOT NULL REFERENCES systems,
	timestamp		TIMESTAMP NOT NULL,
	sigil			VARCHAR(10) NOT NULL,
	comment			VARCHAR(255)

);
GRANT ALL ON annotations_annotationid_seq TO loggerithim;
GRANT ALL ON annotations TO loggerithim;
