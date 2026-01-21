CREATE TABLE [dbo].[ENUM] (
    [SHIFTDATE] date NULL,
    [SITE_CODE] nvarchar(5) NULL,
    [CLIID] int NULL,
    [ENUMNAME] nvarchar(200) NULL,
    [NUM] int NULL,
    [NAME] nvarchar(200) NULL,
    [ABBREV] nvarchar(200) NULL,
    [FLAGS] varchar(50) NULL,
    [UTC_CREATED_DATE] datetime NULL
);