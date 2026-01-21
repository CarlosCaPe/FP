CREATE TABLE [Arch].[ENUM] (
    [ID] decimal(19,0) NOT NULL,
    [ENUMTYPEID] decimal(19,0) NOT NULL,
    [IDX] int NULL,
    [DESCRIPTION] varchar(64) NULL,
    [ABBREVIATION] varchar(32) NULL,
    [FLAGS] int NOT NULL,
    [UTC_CREATED_DATE] datetime NOT NULL,
    [UTC_LOGICAL_DELETED_DATE] datetime NULL,
    [SITECODE] varchar(4) NOT NULL
);