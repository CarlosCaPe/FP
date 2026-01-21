CREATE TABLE [dbo].[MMT_LOCATION_STG] (
    [SITE_CODE] varchar(4) NOT NULL,
    [DISPATCH_LOCATION_ID] varchar(200) NOT NULL,
    [LOCATION_TYPE_CODE] varchar(200) NULL,
    [LOCATION_SUBTYPE_CODE] varchar(200) NULL,
    [MIN_SHIFTDATE] date NULL,
    [MAX_SHIFTDATE] date NULL,
    [PIT_NAME] varchar(200) NULL,
    [PUSHBACK_NAME] varchar(200) NULL,
    [LOCATION_GROUP_1] varchar(200) NULL,
    [LOCATION_GROUP_2] varchar(200) NULL,
    [ELEV] decimal(10,5) NULL,
    [LOCATION_GEO_TEXT] varchar(200) NULL,
    [CREATED_BY] varchar(200) NULL,
    [CREATED_TS] datetime NULL,
    [LAST_UPDATED_BY] varchar(200) NULL,
    [LAST_UPDATED_TS] datetime NULL
);