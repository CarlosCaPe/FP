CREATE TABLE [mor].[EqmtStatusDuration_stg] (
    [shiftid] decimal(19,0) NULL,
    [eqmt] varchar(50) NULL,
    [Duration] numeric(18,0) NULL,
    [StartDateTime] datetime NULL,
    [EndDateTime] datetime NULL,
    [Category] int NULL,
    [Category_desc] varchar(100) NULL
);