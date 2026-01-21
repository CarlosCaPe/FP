CREATE TABLE [dbo].[operator_personnel_map_stg] (
    [SITE_CODE] varchar(5) NOT NULL,
    [SHIFTINDEX] int NOT NULL,
    [OPERATOR_ID] varchar(10) NOT NULL,
    [PERSONNEL_ID] varchar(10) NULL,
    [CREW] varchar(200) NULL,
    [FULL_NAME] varchar(200) NULL,
    [FIRST_NAME] varchar(200) NULL,
    [LAST_NAME] varchar(200) NULL,
    [FIRST_LAST_NAME] varchar(200) NULL,
    [UTC_CREATED_DATE] datetime NULL
);