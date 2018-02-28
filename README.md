# Albion Banner Error Logging

This is a custom package created to asynchronously log errors that occur in locally developed Banner programs.

## Purpose

This is primarily for use during automated integrations to provide logging and eventual notification by a log monitor.

The GZKERRL stored package will allow creation and maintenance of error log records in the GZRERRL table.

These error messages will be categorized by the application name, process, and action being performed by the raising program.

Monitoring will be covered by external reporting software, likely based upon a scheduled report, though it is possible to drive email notificaitons semi-synchronously by trigger or a regularly running database job as a watcher.

This system allows for logs to be commited even if calling application data is rolled back.  PRAGMA AUTONOMOUS_TRANSACTION is used to do this.

## Setup

Create GZRERAP and GZRERRL tables using `gzrerap.sql` and `gzrerap.sql`.

Install packages with build.sql script.

This can be added to a local mass compile script and included in a sub directory via

```sql

--
-- Start compiling Albion custom Error Logging module
--
connect albinst/&&albinst_password
define build_dir = 'error-logging/'
start &&build_dir.build;
undefine build_dir
```

## Usage

### Adding an application

When adding a new application to be logged, it most be added to the GZRERAP table to not be considered an unhandled exception.

The script below should provide a framework for maintaining this table.

```sql
INSERT INTO GZRERAP (
  GZRERAP_APPLICATION,
  GZRERAP_DESC
)
  SELECT
    '$APPLICATION'
    , '$APPLICATION_DESCRIPTION'
  FROM DUAL
  WHERE
    NOT EXISTS(
      SELECT 'X'
      FROM GZRERAP
      WHERE
        GZRERAP_APPLICATION = '$APPLICATION'
    )
```

### Logging errors

Here is an example logging process from our student directory build script.

```sql
  BEGIN
--
    gzkerrl.p_set_log_application_context('CAMPUS_DIRECTORY');
    gzkerrl.p_set_log_process_context('BUILD_STUDIR');
--
    LOOP
      BEGIN
--
        gzkerrl.p_set_log_action_context('LOOP_FETCH');
--
        FETCH STUDENTS_C INTO STUDENTS_REC;
        EXIT WHEN STUDENTS_C%NOTFOUND;
--
        gzkerrl.p_set_log_action_context('LOOP_INSERT');
--
        INSERT INTO STUDENT_DIRECTORY
        VALUES STUDIR_REC;
--
        v_record_count := v_record_count + 1;
        EXCEPTION
        WHEN OTHERS
        THEN
          gzkerrl.p_log_errors(
              p_additional_info => 'PIDM: ' || STUDIR_REC.PIDM
          );
      END;
    END LOOP;
--
    gzkerrl.p_set_log_action_context('CLOSE');
--
    CLOSE STUDENTS_C;
--
    gzkerrl.p_set_log_action_context('COMMIT');
--
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Students Records inserted = ' || v_record_count);
    EXCEPTION
    WHEN NO_DATA_FOUND
    THEN NULL;
    WHEN OTHERS
    THEN
      gzkerrl.p_log_errors();
  END;
```

### Evaluating errors

We have an Argos report for each defined application that emails errors periodically.

Any error recorded for an application not in GZRERAP (thus no Argos report) is picked up by a "unhandled exceptions report".
