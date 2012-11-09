CREATE SEQUENCE users_userid_seq;
CREATE TABLE users (
	userid 		BIGINT CONSTRAINT pk_userid
		NOT NULL PRIMARY KEY DEFAULT nextval('users_userid_seq'),
	username 	VARCHAR(50) NOT NULL UNIQUE,
	password 	VARCHAR(50) NOT NULL,
	preferences TEXT,
	fullname 	VARCHAR(50)
);
GRANT ALL on users_userid_seq TO loggerithim;
GRANT ALL on users TO loggerithim;
