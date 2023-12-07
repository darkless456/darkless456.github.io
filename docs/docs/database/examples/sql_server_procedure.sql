USE [<SIT_DB_SCHEMA_NAME>];

SET
  ANSI_NULLS ON
GO
SET
  QUOTED_IDENTIFIER ON
GO
SET
  ANSI_PADDING ON
GO

BEGIN
  BEGIN TRY

    BEGIN TRAN
      DECLARE @default_department_shortname NVARCHAR(255);
      DECLARE @department_id CHAR(24);
      SET @default_department_shortname = N'PM';
      SELECT
        TOP 1
        @department_id = id
      FROM
        [dbo].[departments]
      WHERE
        shortname = @default_department_shortname;
      IF @department_id is NULL
        BEGIN
          DECLARE @custom_error_message NVARCHAR(200);
          SET @custom_error_message = N'Cannot find the department named ' + @default_department_shortname;
          THROW 50001, @custom_error_message, 1;
        END

      IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_departments]') AND type in (N'U'))
        BEGIN
          CREATE TABLE user_departments(
            id CHAR(24) PRIMARY KEY,
            userId CHAR(24),
            departmentId CHAR(24),
            createdAt DATETIMEOFFSET,
            updatedAt DATETIMEOFFSET,
            isAdmin INT NOT NULL DEFAULT 0
          );
        END
      ELSE
        BEGIN
          ALTER TABLE [dbo].[user_departments] ALTER COLUMN updatedAt DATETIMEOFFSET NULL;
        END

      DECLARE @current_time DATETIMEOFFSET
      DECLARE @user_department_primary_id CHAR(24);
      DECLARE @user_id CHAR(24);
      DECLARE current_user_id CURSOR LOCAL FOR
      SELECT
        DISTINCT users.id
      FROM
        [dbo].[users] AS users
      WHERE
        domain = 'TMS' AND source = 'EXT';
      SET @current_time = GETDATE();

      OPEN current_user_id;
      FETCH NEXT FROM current_user_id INTO @user_id;
      WHILE(@@FETCH_STATUS = 0)
        BEGIN
          SET @user_department_primary_id = LOWER(LEFT(REPLACE(CONVERT(CHAR(36), NEWID()), '-', ''), 24));
          INSERT INTO [dbo].[user_departments]
            ([id], [userId], [departmentId], [createdAt], [isAdmin])
          VALUES
            (@user_department_primary_id, @user_id, @department_id, @current_time, 0);
          FETCH NEXT FROM current_user_id INTO @user_id;
        END
      CLOSE current_user_id;
      DEALLOCATE current_user_id;
    COMMIT TRAN

  END TRY

  BEGIN CATCH
    DECLARE @error_num INT;
    DECLARE @error_state TINYINT;
    DECLARE @error_message NVARCHAR(2048);
    DECLARE @error_severity INT;
    SET @error_num = ERROR_NUMBER();
    SET @error_state = ERROR_STATE();
    SET @error_message = ERROR_MESSAGE();
    SET @error_severity = ERROR_SEVERITY();
    ROLLBACK;
    IF @error_num > 50000
      THROW @error_num, @error_message, @error_state;
    ELSE
      RAISERROR(@error_message, @error_severity, @error_state);
  END CATCH
END
