CREATE SEQUENCE departments_departmentid_seq;
CREATE TABLE departments (
	departmentid 	BIGINT CONSTRAINT pk_department
		NOT NULL PRIMARY KEY DEFAULT nextval('departments_departmentid_seq'),
	name 		VARCHAR(50) NOT NULL UNIQUE
);
GRANT ALL ON departments_departmentid_seq TO loggerithim;
GRANT ALL ON departments TO loggerithim;

INSERT INTO departments (name)
	VALUES ('Production');
