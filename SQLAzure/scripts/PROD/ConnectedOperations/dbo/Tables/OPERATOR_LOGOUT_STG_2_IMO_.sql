CREATE TABLE [dbo].[OPERATOR_LOGOUT_STG_2_IMO_] (
    [SITE_CODE] varchar(4) NOT NULL,
    [SHIFT_OPER_ID] bigint NULL,
    [SHIFTINDEX] int NOT NULL,
    [SHIFTDATE] date NULL,
    [OPERID] varchar(100) NOT NULL,
    [OPER_NAME] varchar(200) NULL,
    [CREW] varchar(50) NULL,
    [EQMT] varchar(50) NOT NULL,
    [FIELDLOGIN] int NOT NULL,
    [FIELDLOGIN_TS] datetime NULL,
    [STATUS] varchar(50) NULL,
    [UTC_CREATED_DATE] datetime NULL
);