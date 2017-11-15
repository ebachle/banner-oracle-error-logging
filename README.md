# Albion Banner Error Logging

This is a custom package created to asynchronously log errors that occur in locally developed Banner programs.

## Purpose

This is primarily for use during automated integrations to provide logging and eventual notification by a log monitor.

The GZKERRL stored package will allow creation and maintenance of error log records in the GZRERRL table.

These error messages will be categorized by the application name, process, and action being performed by the raising program.

Monitoring will be covered by external reporting software, likely based upon a scheduled report, though it is possible to drive email notificaitons semi-synchronously by trigger or a regularly running database job as a watcher.

## Maintaing Error Logging

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
