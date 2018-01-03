--
-- Create Table
-- gzrerap.sql
--
-- AUDIT TRAIL: 8.9.3
-- 1. Create new table GZRERAP. ENB 11/15/2017
--    Created to store application names for which error logging is enabled.
--    This will allow for applications in GZRERRL not in this table to be an 
--    implicit list of "unhandled" exception applications.
--    Applications should be added to this table once they've got a scheduled
--    report delivering the logs to an application admin.
-- 
-- AUDIT TRAIL END
--
DROP TABLE GZRERAP;
CREATE TABLE GZRERAP
(
	GZRERAP_APPLICATION VARCHAR2(50) NOT NULL,
	GZRERAP_DESC VARCHAR2(255) NOT NULL,
	GZRERAP_ACTIVITY_DATE DATE DEFAULT SYSDATE NOT NULL
	/* Will be added by DBEU calls further down the script */
	-- 	GZRERAP_SURROGATE_ID NUMBER(19),
	-- 	GZRERAP_VERSION NUMBER(19),
	-- 	GZRERAP_USER_ID VARCHAR2(30),
	-- 	GZRERAP_DATA_ORIGIN VARCHAR2(30),
	-- 	GZRERAP_VPDI_CODE VARCHAR2(6)
);
CREATE INDEX GZRERAP_MAIN_INDEX
	ON GZRERAP (GZRERAP_APPLICATION);
--
COMMENT ON TABLE GZRERAP IS
'Logged applications table for Albion processes.';
COMMENT ON COLUMN GZRERAP.GZRERAP_APPLICATION IS
'Application is a key field for the error log associated with top-level processes.';
COMMENT ON COLUMN GZRERAP.GZRERAP_DESC IS
'High-level description of each application and its role.';
--
GRANT SELECT, INSERT, UPDATE, DELETE ON GZRERAP TO USR_INFOSERV;
GRANT SELECT, INSERT, UPDATE, DELETE ON GZRERAP TO ALBINST;

BEGIN
	dbeu_owner.dbeu_util.teardown_table(gb_common.f_sct_user(), 'GZRERAP');
	dbeu_owner.dbeu_util.process_table(gb_common.f_sct_user(), 'GZRERAP');
	dbeu_owner.dbeu_util.apply_table(gb_common.f_sct_user(), 'GZRERAP');
	dbeu_owner.dbeu_util.extend_table(gb_common.f_sct_user(), 'GZRERAP', 'G', FALSE);
END;
/

WHENEVER SQLERROR CONTINUE;
DROP PUBLIC SYNONYM GZRERAP;
WHENEVER SQLERROR EXIT ROLLBACK;
CREATE PUBLIC SYNONYM GZRERAP FOR GZRERAP;
