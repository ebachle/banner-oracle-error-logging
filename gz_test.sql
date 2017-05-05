CREATE OR REPLACE PACKAGE gz_test AS
	PROCEDURE P_CREATE(p_test EBACHLE.TEST.TEST%TYPE);
END;

CREATE OR REPLACE PACKAGE BODY gz_test AS

	v_application CONSTANT GZRERRL.GZRERRL_APPLICATION%TYPE := 'TEST';
	v_process CONSTANT GZRERRL.GZRERRL_PROCESS%TYPE := 'TESTING';

		not_t EXCEPTION;
PRAGMA EXCEPTION_INIT (not_t, -20000);


	PROCEDURE P_CREATE(p_test EBACHLE.TEST.TEST%TYPE)
	IS
		BEGIN
			IF p_test = 'T'
			THEN
				INSERT INTO ebachle.test (TEST) VALUES (p_test);
			ELSE
				RAISE_APPLICATION_ERROR(-20000, 'Value is not ''T''. Actual: ' || p_test, TRUE);
			END IF;
			EXCEPTION WHEN OTHERS THEN
			GZKERRL.P_WRITE_ERROR_LOG(
				p_application => v_application
				, p_process => v_process
				, p_action => 'INSERT'
				, p_error => SQLCODE
				, p_message => SQLERRM
			);
		END P_CREATE;
END;

BEGIN
	gz_test.P_CREATE('Z');
END;
COMMIT;