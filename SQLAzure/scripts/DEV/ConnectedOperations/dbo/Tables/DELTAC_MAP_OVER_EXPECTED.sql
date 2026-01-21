CREATE TABLE [dbo].[DELTAC_MAP_OVER_EXPECTED] (
    [SITE_CODE] varchar(5) NOT NULL,
    [ROUTE_NAME] varchar(128) NOT NULL,
    [SEQUENCE] int NOT NULL,
    [LONGITUDE] decimal(18,10) NOT NULL,
    [LATITUDE] decimal(18,10) NOT NULL,
    [EASTING] decimal(18,2) NOT NULL,
    [NORTHING] decimal(18,2) NOT NULL,
    [SECONDS_OVER_EXPECTED] decimal(18,2) NOT NULL,
    [COLOR] varchar(128) NOT NULL
);