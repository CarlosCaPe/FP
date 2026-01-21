CREATE TABLE [dbo].[OPERATOR_LOGOUT_STG] (
    [SITE_CODE] varchar(4) NULL,
    [SHIFT_OPER_ID] bigint NULL,
    [SHIFTINDEX] int NULL,
    [SHIFTDATE] date NULL,
    [OPERID] int NULL,
    [OPER_NAME] varchar(200) NULL,
    [CREW] varchar(50) NULL,
    [EQMT] varchar(50) NULL,
    [FIELDLOGIN] int NULL,
    [FIELDLOGIN_TS] datetime NULL,
    [STATUS] varchar(50) NULL,
    [UTC_CREATED_DATE] datetime NULL
);