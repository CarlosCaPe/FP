CREATE TABLE [dbo].[RCS_RIG] (
    [ORIG_SRC_ID] bigint NULL,
    [SITE_CODE] varchar(5) NULL,
    [RIG_ID] varchar(36) NULL,
    [RIG_NAME] varchar(256) NULL,
    [SERIAL_NUMBER] varchar(64) NULL,
    [RIG_INFORMATION_TS] datetime2 NULL,
    [EXPORT_PATH] varchar(256) NULL,
    [RRA_STATUS_ID] varchar(36) NULL,
    [HAS_GPS] bigint NULL,
    [EQUIPMENT_TYPE_ID] varchar(36) NULL,
    [DW_LOGICAL_DELETE_FLAG] varchar(1) NULL,
    [DW_MODIFY_TS] datetime2 NULL,
    [DW_LOAD_TS] datetime2 NULL
);