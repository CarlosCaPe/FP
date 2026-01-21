CREATE TABLE [dbo].[DELTAC_MAP_LABELS] (
    [SITE_CODE] varchar(5) NOT NULL,
    [LOC] varchar(128) NOT NULL,
    [UNIT] varchar(128) NOT NULL,
    [LONGITUDE] decimal(18,10) NOT NULL,
    [LATITUDE] decimal(18,10) NOT NULL,
    [EASTING] decimal(18,2) NOT NULL,
    [NORTHING] decimal(18,2) NOT NULL
);