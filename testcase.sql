DECLARE
	p_application gzrerrl.gzrerrl_application%TYPE := 'Test Upload App';
	p_process gzrerrl.gzrerrl_process%TYPE := 'INSERT_TEST_TABLE';
	p_action gzrerrl.gzrerrl_action%TYPE := 'INSERT';
	p_error gzrerrl.gzrerrl_error%TYPE;
	p_message gzrerrl.gzrerrl_message%TYPE;
BEGIN
	INSERT INTO EBACHLE.TEST_TABLE VALUES (2);
	gb_common.p_commit;
	EXCEPTION
	WHEN OTHERS THEN
	p_error := SQLCODE;
	p_message := SUBSTR(SQLERRM, 0, 2000);
	GZKERRL.P_WRITE_ERROR_LOG(
		p_application,
		p_process,
		p_action,
		p_error,
		p_message
	);
	gb_common.p_rollback;
END;

select * from gzrerrl;

select * from ebachle.test_table;