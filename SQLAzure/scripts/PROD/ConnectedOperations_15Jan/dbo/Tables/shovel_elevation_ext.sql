CREATE TABLE [dbo].[shovel_elevation_ext] (
    [siteflag] varchar(5) NOT NULL,
    [ShiftId] decimal(19,0) NOT NULL,
    [SENSOR_ID] varchar(255) NOT NULL,
    [shovelId] varchar(5) NULL,
    [SENSOR_VALUE] numeric(18,5) NULL,
    [VALUE_UTC_TS] datetime NOT NULL,
    [UTC_CREATED_DATE] datetime NULL
);