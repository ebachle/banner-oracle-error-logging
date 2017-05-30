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
    p_context VARCHAR2
  ) IS
    BEGIN
      gb_common.p_set_context(C_PACKAGE, C_APPLICATION, p_context, 'N');
    END p_set_log_application_context;
--
  PROCEDURE p_set_log_process_context(
    p_context VARCHAR2
  ) IS
    BEGIN
      gb_common.p_set_context(C_PACKAGE, C_PROCESS, p_context, 'N');
    END p_set_log_process_context;
--
  PROCEDURE p_set_log_action_context(
    p_context VARCHAR2
  ) IS
    BEGIN
      gb_common.p_set_context(C_PACKAGE, C_ACTION, p_context, 'N');
    END p_set_log_action_context;
--
  PROCEDURE p_log_errors(
    p_sql_error NUMBER,
    p_sql_message VARCHAR2,
    p_additional_info VARCHAR2
  ) IS
    v_application gzrerrl.gzrerrl_application%TYPE;
    v_process gzrerrl.gzrerrl_process%TYPE;
    v_action gzrerrl.gzrerrl_action%TYPE;
    v_error gzrerrl.gzrerrl_error%TYPE;
    v_message gzrerrl.gzrerrl_message%TYPE;
--
    error_table gb_common.msgtab;
--
    BEGIN
--
-- Get logging context from global GB_COMMON context.
--
      v_application := f_get_log_application_context();
      v_process := f_get_log_process_context();
      v_action := f_get_log_action_context();
--
-- Build error table from Banner common error handling.
--
      error_table := gb_common.F_ERR_MSG_REMOVE_DELIM_TBL(p_sql_message);
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
        v_error := p_sql_error;
        v_message := substr(error_table(i), 3800) || ' - ' || p_additional_info;
        p_write_error_log(
          p_application => v_application,
          p_process => v_process,
          p_action => v_action,
          p_error => v_error,
          p_message => v_message
        );
      END LOOP;
    END p_log_errors;
--
  PROCEDURE p_write_error_log(
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
        'Failed to insert into GZRERRL table.'
      );
    END p_write_error_log;
END GZKERRL;
/
SHOW ERRORS;
