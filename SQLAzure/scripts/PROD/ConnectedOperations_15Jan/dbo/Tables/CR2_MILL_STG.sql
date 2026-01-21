CREATE TABLE [dbo].[CR2_MILL_STG] (
    [SHIFTINDEX] numeric(38,0) NOT NULL,
    [SITEFLAG] varchar(3) NOT NULL,
    [COMPONENT] varchar(256) NOT NULL,
    [SENSOR_VALUE] varchar(256) NULL,
    [UTC_CREATED_DATE] datetime NULL
);