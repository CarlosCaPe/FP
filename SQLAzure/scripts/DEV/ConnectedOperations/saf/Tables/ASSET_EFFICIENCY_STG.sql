CREATE TABLE [saf].[ASSET_EFFICIENCY_STG] (
    [shiftid] varchar(50) NOT NULL,
    [eqmt] varchar(50) NOT NULL,
    [FieldEqmttype] int NULL,
    [eqmttype] varchar(50) NULL,
    [UnitType] varchar(50) NULL,
    [StartDateTime] datetime NOT NULL,
    [EndDateTime] datetime NULL,
    [Duration] numeric(18,0) NULL,
    [StatusIdx] int NULL,
    [Status] varchar(50) NULL,
    [CategoryIdx] int NULL,
    [Category] varchar(50) NULL,
    [reasonidx] int NULL,
    [reasons] varchar(200) NULL,
    [comments] varchar(500) NULL,
    [UTC_CREATED_DATE] datetime NULL
);