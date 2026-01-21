CREATE TABLE [dbo].[EQMT_SHOVEL_HOURLY_SPOTLOADIDLETIME_STG] (
    [site_code] varchar(4) NOT NULL,
    [shiftindex] decimal(17,0) NOT NULL,
    [Equipment] varchar(50) NOT NULL,
    [idletime] decimal(9,0) NULL,
    [spottime] decimal(9,0) NULL,
    [loadtime] decimal(9,0) NULL,
    [UTC_CREATED_DATE] datetime NULL
);