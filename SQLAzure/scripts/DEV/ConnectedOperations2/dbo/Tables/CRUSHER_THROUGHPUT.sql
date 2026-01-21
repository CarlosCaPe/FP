CREATE TABLE [dbo].[CRUSHER_THROUGHPUT] (
    [SHIFTINDEX] numeric(38,0) NOT NULL,
    [SITEFLAG] varchar(5) NOT NULL,
    [VALUE_TS] datetime NOT NULL,
    [CRUSHERLOC] varchar(50) NOT NULL,
    [COMPONENT] varchar(50) NOT NULL,
    [SENSORVALUE] decimal(38,10) NULL,
    [UTC_CREATED_DATE] datetime NOT NULL
);