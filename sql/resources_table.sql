CREATE SEQUENCE resources_resourceid_seq;
CREATE TABLE resources (
	resourceid	BIGINT CONSTRAINT pk_resources
		NOT NULL PRIMARY KEY DEFAULT nextval('resources_resourceid_seq'),
	resgroupid	BIGINT NOT NULL REFERENCES resgroups,
	name		VARCHAR(30) NOT NULL UNIQUE,
	index		SMALLINT NOT NULL
);
GRANT ALL ON resources_resourceid_seq TO loggerithim;
GRANT ALL ON resources TO loggerithim;
INSERT INTO resources (name, index, resgroupid) VALUES
	('memAvailSwap', 0, 1);
INSERT INTO resources (name, index, resgroupid) VALUES
	('memAvailReal', 1, 1);
INSERT INTO resources (name, index, resgroupid) VALUES
	('memBuffered', 2, 1);
INSERT INTO resources (name, index, resgroupid) VALUES
	('memCached', 3, 1);
INSERT INTO resources (name, index, resgroupid) VALUES
	('cpuUser', 0, 2);
INSERT INTO resources (name, index, resgroupid) VALUES
	('cpuSys', 1, 2);
INSERT INTO resources (name, index, resgroupid) VALUES
	('cpuIdle', 2, 2);
INSERT INTO resources (name, index, resgroupid) VALUES
	('miscPagesIn', 0, 3);
INSERT INTO resources (name, index, resgroupid) VALUES
	('miscPagesOut', 1, 3);
INSERT INTO resources (name, index, resgroupid) VALUES
	('miscSwapIn', 2, 3);
INSERT INTO resources (name, index, resgroupid) VALUES
	('miscSwapOut', 3, 3);
INSERT INTO resources (name, index, resgroupid) VALUES
	('loaLoad1', 0, 4);
INSERT INTO resources (name, index, resgroupid) VALUES
	('loaLoad2', 1, 4);
INSERT INTO resources (name, index, resgroupid) VALUES
	('loaLoad3', 2, 4);
INSERT INTO resources (name, index, resgroupid) VALUES
	('ifName', 0, 5);
INSERT INTO resources (name, index, resgroupid) VALUES
	('ifInKBytes', 1, 5);
INSERT INTO resources (name, index, resgroupid) VALUES
	('ifOutKBytes', 2, 5);
INSERT INTO resources (name, index, resgroupid) VALUES
	('memTotalSwap', 0, 6);
INSERT INTO resources (name, index, resgroupid) VALUES
	('memTotalReal', 1, 6);
INSERT INTO resources (name, index, resgroupid) VALUES
	('sysUptime', 2, 6);
INSERT INTO resources (name, index, resgroupid) VALUES
	('sysOS', 3, 6);
INSERT INTO resources (name, index, resgroupid) VALUES
	('sysOSVer', 4, 6);
INSERT INTO resources (name, index, resgroupid) VALUES
	('stoName', 0, 7);
INSERT INTO resources (name, index, resgroupid) VALUES
	('stoSize', 1, 7);
INSERT INTO resources (name, index, resgroupid) VALUES
	('stoUsed', 2, 7);
INSERT INTO resources (name, index, resgroupid) VALUES
	('stoAvail', 3, 7);
INSERT INTO resources (name, index, resgroupid) VALUES
	('stoPercent', 4, 7);
INSERT INTO resources (name, index, resgroupid) VALUES
	('stoDevice', 5, 7);
