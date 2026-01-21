CREATE TABLE [saf].[ALERT] (
    [SHIFTINDEX] numeric(38,0) NOT NULL,
    [SITEFLAG] varchar(5) NOT NULL,
    [EQMT_TYPE] varchar(50) NULL,
    [EQMTID] varchar(50) NOT NULL,
    [OPERATOR_ID] varchar(50) NULL,
    [ALERT_TYPE] varchar(50) NOT NULL,
    [ALERT_NAME] varchar(150) NULL,
    [ALERT_DESCRIPTION] varchar(150) NULL,
    [ALERT_DATE] datetime NULL,
    [DURATION] varchar(50) NULL,
    [ALERT_GENERATED_DATETIME] datetime NULL,
    [UTC_CREATED_DATE] datetime NULL
);