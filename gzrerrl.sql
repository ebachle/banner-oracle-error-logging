--
-- Create Table
-- gzrerrl.sql
--
-- AUDIT TRAIL: 8.8                      INIT    DATE
-- 1. Create new table GZRERRL           ENB     09/20/2016
--    Created to house errors recorded from locally developed apps.
-- 2. Added default location values      ENB     05/05/2016
--    Not all logging sources will necessarily have cause for defining an APPLICATION, PROCESS, and ACTION.
--    This will allow for fall-through error logging of unhandled exceptions.
-- AUDIT TRAIL END
--
DROP TABLE GZRERRL;
CREATE TABLE GZRERRL
(
	GZRERRL_APPLICATION VARCHAR2(20) DEFAULT 'UNDEFINED' NOT NULL,
	GZRERRL_PROCESS VARCHAR2(50) DEFAULT 'UNDEFINED' NOT NULL,
	GZRERRL_ACTION VARCHAR2(20) DEFAULT 'UNDEFINED' NOT NULL,
	GZRERRL_TIMESTAMP DATE DEFAULT SYSDATE NOT NULL,
	GZRERRL_ERROR VARCHAR2(200) NOT NULL,
	GZRERRL_MESSAGE VARCHAR2(4000),
	GZRERRL_STATUS VARCHAR2(20) DEFAULT 'NEW' NOT NULL,
	/* Will be added by DBEU calls further down the script */
	-- 	GZRERRL_SURROGATE_ID NUMBER(19),
	-- 	GZRERRL_VERSION NUMBER(19),
	-- 	GZRERRL_USER_ID VARCHAR2(30),
	-- 	GZRERRL_DATA_ORIGIN VARCHAR2(30),
	-- 	GZRERRL_VPDI_CODE VARCHAR2(6)
);
CREATE INDEX GZRERRL_MAIN_index
	ON (GZRERRL_APPLICATION, GZRERRL_PROCESS, GZRERRL_ACTION, GZRERRL_TIMESTAMP, GZRERRL_STATUS)
CREATE INDEX GZRERRL_TIMESTAMP_index
	ON GZRERRL (GZRERRL_TIMESTAMP);
CREATE INDEX GZRERRL_ERROR_index
	ON GZRERRL (GZRERRL_ERROR);
COMMENT ON TABLE GZRERRL IS 'Error Logging Table for Albion processes';
GRANT SELECT, INSERT, UPDATE, DELETE ON GZRERRL TO USR_INFOSERV;
GRANT SELECT, INSERT, UPDATE, DELETE ON GZRERRL TO ALBINST;

BEGIN
	dbeu_owner.dbeu_util.teardown_table(gb_common.f_sct_user(), 'GZRERRL');
	dbeu_owner.dbeu_util.process_table(gb_common.f_sct_user(), 'GZRERRL');
	dbeu_owner.dbeu_util.apply_table(gb_common.f_sct_user(), 'GZRERRL');
	dbeu_owner.dbeu_util.extend_table(gb_common.f_sct_user(), 'GZRERRL', 'G', FALSE);
END;
/

WHENEVER SQLERROR CONTINUE;
DROP PUBLIC SYNONYM gzrerrl;
WHENEVER SQLERROR EXIT ROLLBACK;
CREATE PUBLIC SYNONYM gzrerrl FOR gzrerrl;
