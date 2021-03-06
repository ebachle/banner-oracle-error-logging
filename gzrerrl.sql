--
-- Create Table
-- gzrerrl.sql
--
-- AUDIT TRAIL: 8.8                      INIT    DATE
-- 1. Create new table GZRERRL           ENB     09/20/2016
--    Created to house errors recorded from locally developed apps.
-- 2. Added default location values      ENB     05/05/2017
--    Not all logging sources will necessarily have cause for defining an APPLICATION, PROCESS, and ACTION.
--    This will allow for fall-through error logging of unhandled exceptions.
-- 3. Converted field type to INTEGER    ENB     06/01/2017
--    Converted gzrerrl_error type to integer to match SQLCODE return type.
-- 4. Added additional fields.           ENB     06/01/2017
--    Field was added for trace to be filled by DBMS_UTILITY.FORMAT_FORMAT_ERROR_BACKTRACE();
--    Field was added for logging additional info to give context to what record threw the error in ETL usually.
-- 5. Extended fields                    ENB     06/01/2017
--    Extended application and action fields just for sanity.
--    Could be smaller, but overall, they may have cause to get that large given all the uses this may see.
--    Additional error handling will be added to the GZKERRL package to clarify when these limits are exceeded.
--
-- AUDIT TRAIL: 8.9.3
-- 1. ENB 11/15/2017
--    Added column comments.
-- 2. ENB 11/15/2017
--    Revoked grants to USR_INFOSERV to prevent log tampering.
--
-- AUDIT TRAIL END
--
DROP TABLE GZRERRL;
CREATE TABLE GZRERRL
(
	GZRERRL_APPLICATION VARCHAR2(50) DEFAULT 'UNDEFINED' NOT NULL,
	GZRERRL_PROCESS VARCHAR2(50) DEFAULT 'UNDEFINED' NOT NULL,
	GZRERRL_ACTION VARCHAR2(50) DEFAULT 'UNDEFINED' NOT NULL,
	GZRERRL_TIMESTAMP DATE DEFAULT SYSDATE NOT NULL,
	GZRERRL_ERROR INTEGER NOT NULL,
	GZRERRL_MESSAGE VARCHAR2(4000),
	GZRERRL_TRACE VARCHAR2(4000),
	GZRERRL_ADDITIONAL_INFO VARCHAR2(4000),
	GZRERRL_STATUS VARCHAR2(20) DEFAULT 'NEW' NOT NULL
	/* Will be added by DBEU calls further down the script */
	-- 	GZRERRL_SURROGATE_ID NUMBER(19),
	-- 	GZRERRL_VERSION NUMBER(19),
	-- 	GZRERRL_USER_ID VARCHAR2(30),
	-- 	GZRERRL_DATA_ORIGIN VARCHAR2(30),
	-- 	GZRERRL_VPDI_CODE VARCHAR2(6)
);
CREATE INDEX GZRERRL_MAIN_index
	ON GZRERRL (GZRERRL_APPLICATION, GZRERRL_PROCESS, GZRERRL_ACTION, GZRERRL_TIMESTAMP, GZRERRL_STATUS);
CREATE INDEX GZRERRL_TIMESTAMP_index
	ON GZRERRL (GZRERRL_TIMESTAMP);
CREATE INDEX GZRERRL_ERROR_index
	ON GZRERRL (GZRERRL_ERROR);
CREATE INDEX GZRERRL_STATUS_index
	ON GZRERRL (GZRERRL_STATUS);
--
COMMENT ON TABLE GZRERRL IS
'Error Logging Table for Albion processes';
COMMENT ON COLUMN GZRERRL.GZRERRL_APPLICATION IS
'Application is the top-level package being logged';
COMMENT ON COLUMN GZRERRL.GZRERRL_PROCESS IS
'Process is the function of the application being logged';
COMMENT ON COLUMN GZRERRL.GZRERRL_ACTION IS
'Action is the specific act being performed (usually a CRUD behavior) being logged';
COMMENT ON COLUMN GZRERRL.GZRERRL_TIMESTAMP IS
'Timestamp of the logged event.  Should not ever be updated.';
COMMENT ON COLUMN GZRERRL.GZRERRL_ERROR IS
'SQL error code thrown.';
COMMENT ON COLUMN GZRERRL.GZRERRL_MESSAGE IS
'SQL error message thrown.';
COMMENT ON COLUMN GZRERRL.GZRERRL_TRACE IS
'SQL trace from DBMS_UTILITY showing execution path of exception.';
COMMENT ON COLUMN GZRERRL.GZRERRL_ADDITIONAL_INFO IS
'Any additional info passed to the logger by the application for context of error.';
COMMENT ON COLUMN GZRERRL.GZRERRL_STATUS IS
'Status of the error.  Default value of NEW.  Current other values are ACKNOWLEDGED and RESOLVED.';
--
GRANT SELECT, INSERT, UPDATE, DELETE ON GZRERRL TO ALBINST;
--
BEGIN
	dbeu_owner.dbeu_util.teardown_table(gb_common.f_sct_user(), 'GZRERRL');
	dbeu_owner.dbeu_util.process_table(gb_common.f_sct_user(), 'GZRERRL');
	dbeu_owner.dbeu_util.apply_table(gb_common.f_sct_user(), 'GZRERRL');
	dbeu_owner.dbeu_util.extend_table(gb_common.f_sct_user(), 'GZRERRL', 'G', FALSE);
END;
/
--
WHENEVER SQLERROR CONTINUE;
DROP PUBLIC SYNONYM gzrerrl;
WHENEVER SQLERROR EXIT ROLLBACK;
CREATE PUBLIC SYNONYM gzrerrl FOR gzrerrl;
--
