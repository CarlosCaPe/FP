CREATE TABLE [chi].[ENUM_STG] (
    [ID] decimal(19,0) NOT NULL,
    [ENUMTYPEID] decimal(19,0) NOT NULL,
    [IDX] int NULL,
    [DESCRIPTION] varchar(64) NULL,
    [ABBREVIATION] varchar(32) NULL,
    [FLAGS] int NOT NULL,
    [CHANGE_TYPE] varchar(1) NOT NULL,
    [CHANGE_ID] decimal(19,0) NOT NULL,
    [UTC_CREATED_DATE] datetime NOT NULL,
    [UTC_LOGICAL_DELETED_DATE] datetime NULL
);