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
--    Added default values to p_write_error_log spec.
-- 4. ENB 6/1/2017
--    Altered default types of logging context setters.
--    This should prevent strings of an unacceptable length from being set.
--
-- AUDIT TRAIL: 8.9.3
-- 1. ENB 11/15/2017
--    Added constants to abstract log event states.
-- 2. ENB 11/15/2017
--    Added public procedures to update the statues to different options.
--    DML procedure is private in the package body.
-- 3. ENB 11/15/2017
--    Moved DML procedure p_write_log to private package method.
--
-- AUDIT TRAIL END
--
CREATE OR REPLACE PACKAGE GZKERRL AS
--
-- FILE NAME..: gzkerrl.sql
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
-- Constants
--
  C_PACKAGE            CONSTANT VARCHAR2(100) := 'GZKERRL_ERROR_LOGGER';
  C_APPLICATION        CONSTANT VARCHAR2(100) := 'APPLICATION';
  C_PROCESS            CONSTANT VARCHAR2(100) := 'PROCESS';
  C_ACTION             CONSTANT VARCHAR2(100) := 'ACTION';
--
  C_STATUS_NEW CONSTANT gzrerrl.gzrerrl_status%TYPE := 'NEW';
  C_STATUS_ACKNOWLEDGED CONSTANT gzrerrl.gzrerrl_status%TYPE := 'ACKNOWLEDGED';
  C_STATUS_RESOLVED CONSTANT gzrerrl.gzrerrl_status%TYPE := 'RESOLVED';
--
-- Functions
--
  FUNCTION f_get_log_application_context
    RETURN VARCHAR2;
--
  FUNCTION f_get_log_process_context
    RETURN VARCHAR2;
--
  FUNCTION f_get_log_action_context
    RETURN VARCHAR2;
--
-- Procedures
--
  PROCEDURE p_set_log_application_context(
    p_context gzrerrl.gzrerrl_application%TYPE
  );
--
  PROCEDURE p_set_log_process_context(
    p_context gzrerrl.gzrerrl_process%TYPE
  );
--
  PROCEDURE p_set_log_action_context(
    p_context gzrerrl.gzrerrl_action%TYPE
  );
--
  PROCEDURE p_log_errors(
    p_error gzrerrl.gzrerrl_error%TYPE DEFAULT SQLCODE,
    p_message gzrerrl.gzrerrl_message%TYPE DEFAULT DBMS_UTILITY.FORMAT_ERROR_STACK,
    p_trace gzrerrl.gzrerrl_trace%TYPE DEFAULT DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
    p_additional_info gzrerrl.gzrerrl_additional_info%TYPE DEFAULT NULL
  );
--
  PROCEDURE p_mark_new(
    p_id gzrerrl.gzrerrl_surrogate_id%TYPE,
    p_user_id gzrerrl.gzrerrl_user_id%TYPE DEFAULT gb_common.f_sct_user
  );
--
  PROCEDURE p_mark_acknowledged(
    p_id gzrerrl.gzrerrl_surrogate_id%TYPE,
    p_user_id gzrerrl.gzrerrl_user_id%TYPE DEFAULT gb_common.f_sct_user
  );
--
  PROCEDURE p_mark_resolved(
    p_id gzrerrl.gzrerrl_surrogate_id%TYPE,
    p_user_id gzrerrl.gzrerrl_user_id%TYPE DEFAULT gb_common.f_sct_user
  );
--
END GZKERRL;
/
SHOW ERRORS;

SET DEFINE ON
WHENEVER SQLERROR CONTINUE;
DROP PUBLIC SYNONYM gzkerrl;
WHENEVER SQLERROR EXIT ROLLBACK;
CREATE PUBLIC SYNONYM gzkerrl FOR gzkerrl;
REM *** BEGINNING OF GURMDBP MODS ***
REM GRANT EXECUTE ON gzkerrl TO PUBLIC;
WHENEVER SQLERROR CONTINUE
START gurgrtb gzkerrl
START gurgrti gzkerrl
START gurgrts gzkerrl
START gurgrtn gzkerrl
WHENEVER SQLERROR EXIT ROLLBACK
REM *** END OF GURMDBP MODS ***
