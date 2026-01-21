CREATE TABLE [dbo].[RCS_DRILLED_HOLE_VALIDATION] (
    [ORIG_SRC_ID] bigint NULL,
    [SITE_CODE] varchar(4) NULL,
    [DRILLED_HOLE_VALIDATION_ID] varchar(36) NULL,
    [DRILLED_HOLE_ID] varchar(36) NULL,
    [TIME] datetime NULL,
    [ISDEPTHINVALID] bigint NULL,
    [ISDATETIMEINVALID] bigint NULL,
    [ISANGLEINVALID] bigint NULL,
    [ISPOSITIONINVALID] bigint NULL,
    [ISDUPLICATE] bigint NULL,
    [ISUNPLANNED] bigint NULL,
    [ISUPSIDEDOWN] bigint NULL,
    [ISTIMEOVERLAPPING] bigint NULL,
    [DW_LOGICAL_DELETE_FLAG] varchar(1) NULL,
    [DW_MODIFY_TS] datetimeoffset NULL,
    [DW_LOAD_TS] datetimeoffset NULL
);