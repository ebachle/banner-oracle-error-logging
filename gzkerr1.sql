--
-- ****************************************************************************
-- *                                                                          *
-- * Copyright 2016 Albion College                                            *
-- *                                                                          *
-- ****************************************************************************
--
-- AUDIT TRAIL: 8.8
-- 1. ENB 9/20/2016
--    Initial creation of package to write errors to Albion error logging table.
--    Delivered to support ETL load processes.
-- AUDIT TRAIL END
--
CREATE OR REPLACE PACKAGE BODY GZKERRL AS
--
-- FILE NAME..: gzkerr1.sql
-- RELEASE....: 8.8
-- OBJECT NAME: GZKERRL
-- PRODUCT....: ALBION
-- USAGE......: Package to support the Albion custom application error log.
-- COPYRIGHT..: Copyright 2016 Albion College.
--
-- DESCRIPTION:
--
-- This package provides a common interface to write to the Albion application
-- log table.  This will record information on a per-application basis
--
-- DESCRIPTION END
--

	PROCEDURE P_WRITE_ERROR_LOG(
		p_application gzrerrl.gzrerrl_application%TYPE,
		p_process gzrerrl.gzrerrl_process%TYPE,
		p_action gzrerrl.gzrerrl_action%TYPE,
		p_error gzrerrl.gzrerrl_error%TYPE,
		p_message gzrerrl.gzrerrl_message%TYPE
	) IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	  v_user_id CONSTANT GZRERRL.GZRERRL_USER_ID%TYPE := GB_COMMON.F_SCT_USER();
	  v_data_origin CONSTANT GZRERRL.GZRERRL_DATA_ORIGIN%TYPE := 'GZKERRL Error Logger';
		BEGIN
			INSERT INTO GZRERRL (
				GZRERRL_APPLICATION
				, GZRERRL_PROCESS
				, GZRERRL_ACTION
				, GZRERRL_TIMESTAMP
				, GZRERRL_ERROR
				, GZRERRL_MESSAGE
				, GZRERRL_USER_ID
				, GZRERRL_DATA_ORIGIN
				, GZRERRL_ACTIVITY_DATE
			)
			VALUES (
				p_application
				, p_process
				, p_action
				, SYSDATE
				, p_error
				, p_message
				, v_user_id
				, v_data_origin
				, SYSDATE
			);
			gb_common.P_COMMIT();
			EXCEPTION
			WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('Failed to insert into GZRERRL table.');
			RAISE_APPLICATION_ERROR(
				gb_common_strings.err_code,
				gb_common.f_err_msg_add_delim('Failed to insert into GZRERRL table.')
			);
		END P_WRITE_ERROR_LOG;
END GZKERRL;
/
SHOW ERRORS;
