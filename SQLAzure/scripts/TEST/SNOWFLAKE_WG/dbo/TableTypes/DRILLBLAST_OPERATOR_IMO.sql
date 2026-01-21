CREATE TYPE [dbo].[DRILLBLAST_OPERATOR_IMO] AS TABLE (
    [SYSTEM_OPERATOR_ID] bigint NOT NULL,
    [SITE_CODE] varchar(5) NOT NULL,
    [ORIG_SRC_ID] int NULL,
    [APPLICATION_OPERATOR_ID] varchar(255) NULL,
    [OPERATOR_NAME] varchar(255) NULL,
    [CREW_ID] int NULL,
    [CREW_NAME] varchar(255) NULL,
    [SAP_OPERATOR_ID] varchar(255) NULL,
    [EFFECTIVE_START_DATE] varchar(50) NULL,
    [END_DATE] varchar(50) NULL,
    [SYSTEM_VERSION] varchar(255) NULL,
    [DW_LOAD_TS] varchar(50) NULL,
    [DW_MODIFY_TS] varchar(50) NULL
);