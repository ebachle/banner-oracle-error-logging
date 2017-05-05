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
	PROCEDURE P_WRITE_ERROR_LOG(
		p_application gzrerrl.gzrerrl_application%TYPE,
		p_process gzrerrl.gzrerrl_process%TYPE,
		p_action gzrerrl.gzrerrl_action%TYPE,
		p_error gzrerrl.gzrerrl_error%TYPE,
		p_message gzrerrl.gzrerrl_message%TYPE
	);
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
