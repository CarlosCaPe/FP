CREATE TABLE [dbo].[DRILLBLAST_EQUIPMENT_IMO] (
    [ORIG_SRC_ID] int NOT NULL,
    [SITE_CODE] varchar(5) NOT NULL,
    [DRILL_ID] bigint NOT NULL,
    [EQUIP_NAME] varchar(255) NULL,
    [EQUIP_MODEL] varchar(255) NULL,
    [SERIAL_NUMBER] varchar(255) NULL,
    [EQUIP_CATEGORY] varchar(50) NULL,
    [MEM_EQUIP_ID] varchar(255) NULL,
    [EQUIP_UNIT_CODE] int NULL,
    [SAP_EQUIP_NO] varchar(50) NULL,
    [SYSTEM_VERSION] varchar(255) NULL,
    [DW_LOAD_TS] varchar(50) NULL,
    [DW_MODIFY_TS] varchar(50) NULL
);