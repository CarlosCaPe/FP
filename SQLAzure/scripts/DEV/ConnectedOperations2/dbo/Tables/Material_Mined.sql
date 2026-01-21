CREATE TABLE [dbo].[Material_Mined] (
    [siteflag] varchar(3) NOT NULL,
    [shiftid] varchar(10) NOT NULL,
    [shovelid] varchar(10) NOT NULL,
    [TotalMaterialMined] int NULL,
    [TotalMaterialMoved] int NULL,
    [UTC_CREATED_DATE] datetime NOT NULL
);