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
-- 2. ENB 6/1/2017
--    Updated with additional functions to simplify logging multiple errors.
--    Added additional columns to house additional info and traces.
--    Added functions and procedures to get and set logging conext.
--    Added defaults to assist with pulling in logs without many inputs (or any possibly).
-- 3. ENB 6/1/2017
--    Added additional handling of errors inserting into table.
--    Will not output underlying ORA- SQL error and message.
-- 4. ENB 6/1/2017
--    Fixed issue with inserting NULL explicitly in p_write_error_log call.
--    Though underlying table has a default value, this only works if the column is not called explicitly.
--    Added a default value on the function to assist with that.
--    Added NVL logic to the calls to f_get_*_context.  This will get a 'UNDEFINED' value for the INSERT.
-- 5. ENB 6/1/2017
--    Altered default types of logging context setters.
--    This should prevent strings of an unacceptable length from being set.
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
  FUNCTION f_get_log_application_context
      RETURN VARCHAR2
    IS
    BEGIN
      RETURN gb_common.f_get_context(C_PACKAGE, C_APPLICATION);
    END f_get_log_application_context;
--
  FUNCTION f_get_log_process_context
      RETURN VARCHAR2
    IS
    BEGIN
      RETURN gb_common.f_get_context(C_PACKAGE, C_PROCESS);
    END f_get_log_process_context;
--
  FUNCTION f_get_log_action_context
      RETURN VARCHAR2
    IS
    BEGIN
      RETURN gb_common.f_get_context(C_PACKAGE, C_ACTION);
    END f_get_log_action_context;
--
  PROCEDURE p_set_log_application_context(
    p_context gzrerrl.gzrerrl_application%TYPE
  ) IS
    BEGIN
      gb_common.p_set_context(C_PACKAGE, C_APPLICATION, p_context, 'N');
    END p_set_log_application_context;
--
  PROCEDURE p_set_log_process_context(
    p_context gzrerrl.gzrerrl_process%TYPE
  ) IS
    BEGIN
      gb_common.p_set_context(C_PACKAGE, C_PROCESS, p_context, 'N');
    END p_set_log_process_context;
--
  PROCEDURE p_set_log_action_context(
    p_context gzrerrl.gzrerrl_action%TYPE
  ) IS
    BEGIN
      gb_common.p_set_context(C_PACKAGE, C_ACTION, p_context, 'N');
    END p_set_log_action_context;
--
  PROCEDURE p_log_errors(
    p_error gzrerrl.gzrerrl_error%TYPE DEFAULT SQLCODE,
    p_message gzrerrl.gzrerrl_message%TYPE DEFAULT DBMS_UTILITY.FORMAT_ERROR_STACK,
    p_trace gzrerrl.gzrerrl_trace%TYPE DEFAULT DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
    p_additional_info gzrerrl.gzrerrl_additional_info%TYPE DEFAULT NULL
  ) IS
    v_application gzrerrl.gzrerrl_application%TYPE;
    v_process gzrerrl.gzrerrl_process%TYPE;
    v_action gzrerrl.gzrerrl_action%TYPE;
    v_error gzrerrl.gzrerrl_error%TYPE;
    v_message gzrerrl.gzrerrl_message%TYPE;
    v_trace gzrerrl.gzrerrl_trace%TYPE;
    v_additional_info gzrerrl.gzrerrl_additional_info%TYPE;
--
    error_table gb_common.msgtab;
--
    BEGIN
--
-- Get logging context from global GB_COMMON context.
--
      v_application := NVL(f_get_log_application_context(), 'UNDEFINED');
      v_process := NVL(f_get_log_process_context(), 'UNDEFINED');
      v_action := NVL(f_get_log_action_context(), 'UNDEFINED');
--
-- Build error table from Banner common error handling.
--
      error_table := gb_common.F_ERR_MSG_REMOVE_DELIM_TBL(p_message);
--
-- Error checking for empty collection of errors
--
      IF error_table IS NULL
      THEN
        RAISE_APPLICATION_ERROR(gb_common_strings.err_code, 'No error table generated from incoming error message.', TRUE);
      END IF;
      IF error_table.COUNT = 0
      THEN
        RAISE_APPLICATION_ERROR(gb_common_strings.err_code, 'Empty error table generated from incoming error message.', TRUE);
      END IF;
--
      FOR i IN error_table.FIRST .. error_table.LAST
      LOOP
        v_error := p_error;
        v_message := error_table(i);
        v_trace := p_trace;
        v_additional_info := p_additional_info;
        p_write_error_log(
          p_application => v_application,
          p_process => v_process,
          p_action => v_action,
          p_error => v_error,
          p_message => v_message,
          p_trace => v_trace,
          p_additional_info => v_additional_info
        );
      END LOOP;
    END p_log_errors;
--
  PROCEDURE p_write_error_log(
    p_application gzrerrl.gzrerrl_application%TYPE DEFAULT 'UNDEFINED',
    p_process gzrerrl.gzrerrl_process%TYPE DEFAULT 'UNDEFINED',
    p_action gzrerrl.gzrerrl_action%TYPE DEFAULT 'UNDEFINED',
    p_error gzrerrl.gzrerrl_error%TYPE,
    p_message gzrerrl.gzrerrl_message%TYPE,
    p_trace gzrerrl.gzrerrl_trace%TYPE,
    p_additional_info gzrerrl.gzrerrl_additional_info%TYPE
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
        , GZRERRL_TRACE
        , GZRERRL_ADDITIONAL_INFO
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
        , p_trace
        , p_additional_info
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
        'Failed to insert into GZRERRL table.' || SQLCODE || ' - ' || SQLERRM
      );
    END p_write_error_log;
END GZKERRL;
/
SHOW ERRORS;
