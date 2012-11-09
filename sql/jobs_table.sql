CREATE SEQUENCE jobs_jobid_seq;
CREATE TABLE jobs (
	jobid		BIGINT CONSTRAINT pk_jobs
			NOT NULL PRIMARY KEY DEFAULT nextval('jobs_jobid_seq'),
	attributeid	BIGINT NOT NULL REFERENCES attributes,
	smeepletid	BIGINT NOT NULL REFERENCES smeeplets,
	interval	VARCHAR(100) NOT NULL
);
GRANT ALL ON jobs_jobid_seq TO loggerithim;
GRANT ALL ON jobs TO loggerithim;
INSERT INTO jobs (attributeid, smeepletid, interval) VALUES (
	1, 2, '1 7,15 * * *');
