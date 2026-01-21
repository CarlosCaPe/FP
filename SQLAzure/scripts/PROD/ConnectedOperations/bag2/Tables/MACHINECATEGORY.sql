CREATE TABLE [bag2].[MACHINECATEGORY] (
    [SITEFLAG] varchar(5) NOT NULL,
    [MACHINECATEGORY_OID] bigint NOT NULL,
    [ECF_CLASS_ID] nvarchar(255) NOT NULL,
    [IS_ACTIVE] bit NOT NULL,
    [NAME] nvarchar(254) NOT NULL,
    [DESCRIPTION] nvarchar(254) NULL,
    [ICONURL] nvarchar(254) NULL,
    [STATESET] nvarchar(254) NULL,
    [CYCLEENGINE] nvarchar(254) NULL,
    [UTC_CREATED_DATE] datetime NOT NULL,
    [UTC_LOGICAL_DELETED_DATE] datetime NULL
);