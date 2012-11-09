CREATE SEQUENCE notif_notificationid_seq;
CREATE TABLE notifications (
	notificationid 	BIGINT CONSTRAINT pk_notificationid
		NOT NULL PRIMARY KEY DEFAULT nextval('notif_notificationid_seq'),
	jobid 		BIGINT NOT NULL REFERENCES jobs,
	groupid		BIGINT NOT NULL REFERENCES groups,
	systemid	BIGINT REFERENCES systems
);
GRANT ALL ON notif_notificationid_seq TO loggerithim;
GRANT ALL ON notifications TO loggerithim;
