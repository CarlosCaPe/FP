CREATE TYPE [dbo].[OPERATOR_TITLE_STG_2_IMO_] AS TABLE (
    [SITE_CODE] varchar(5) NOT NULL,
    [EMPLOYEE_ID] varchar(50) NOT NULL,
    [DISPLAY_NAME] varchar(200) NULL,
    [JOB_TITLE] varchar(200) NULL,
    [UTC_CREATED_DATE] datetime NULL
);