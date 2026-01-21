CREATE TABLE [dbo].[DELTAC_MAP_BASE_ROADS] (
    [SITE_CODE] varchar(5) NOT NULL,
    [SEG_ID] varchar(128) NOT NULL,
    [SEQUENCE] int NOT NULL,
    [LONGITUDE] decimal(18,10) NOT NULL,
    [LATITUDE] decimal(18,10) NOT NULL,
    [EASTING] decimal(18,2) NOT NULL,
    [NORTHING] decimal(18,2) NOT NULL
);