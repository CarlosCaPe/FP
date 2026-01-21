CREATE TABLE [CLI].[ASSET_EFFICIENCY] (
    [SITEFLAG] varchar(5) NOT NULL,
    [SHIFTID] varchar(50) NOT NULL,
    [EQMT] varchar(50) NOT NULL,
    [FIELDEQMTTYPE] int NULL,
    [EQMTTYPE] varchar(50) NULL,
    [UNITTYPE] varchar(50) NULL,
    [STARTDATETIME] datetime NOT NULL,
    [ENDDATETIME] datetime NULL,
    [DURATION] numeric(18,0) NULL,
    [STATUSIDX] int NULL,
    [STATUS] varchar(50) NULL,
    [CATEGORYIDX] int NULL,
    [CATEGORY] varchar(50) NULL,
    [REASONIDX] int NULL,
    [REASONS] varchar(200) NULL,
    [COMMENTS] varchar(500) NULL,
    [UTC_CREATED_DATE] datetime NULL
);