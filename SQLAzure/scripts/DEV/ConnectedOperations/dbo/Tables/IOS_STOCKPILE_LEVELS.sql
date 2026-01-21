CREATE TABLE [dbo].[IOS_STOCKPILE_LEVELS] (
    [SHIFTINDEX] numeric(38,0) NOT NULL,
    [SITEFLAG] varchar(5) NOT NULL,
    [CRUSHERLOC] varchar(50) NOT NULL,
    [COMPONENT] varchar(50) NOT NULL,
    [VALUE_TS] datetime NULL,
    [SENSORVALUE] decimal(38,10) NULL,
    [UTC_CREATED_DATE] datetime NOT NULL
);