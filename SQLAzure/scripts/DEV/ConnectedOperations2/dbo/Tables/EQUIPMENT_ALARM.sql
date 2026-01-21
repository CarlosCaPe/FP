CREATE TABLE [dbo].[EQUIPMENT_ALARM] (
    [SITE_CODE] varchar(5) NULL,
    [SHIFTINDEX] int NULL,
    [SHIFTDATE] date NULL,
    [SHIFT_CODE] int NULL,
    [EQUIPMENT_ID] varchar(10) NULL,
    [ALARM_NAME] varchar(200) NULL,
    [ALARM_START_TIME] datetime NULL,
    [ALARM_END_TIME] datetime NULL,
    [UTC_CREATED_DATE] datetime NULL
);