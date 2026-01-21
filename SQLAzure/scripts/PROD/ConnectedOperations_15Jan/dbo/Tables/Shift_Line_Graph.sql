CREATE TABLE [dbo].[Shift_Line_Graph] (
    [siteflag] varchar(3) NOT NULL,
    [shiftid] varchar(10) NOT NULL,
    [shovelid] varchar(6) NOT NULL,
    [TotalMaterialMined] int NULL,
    [TotalMaterialMoved] int NULL,
    [Waste] int NULL,
    [Mill] int NULL,
    [CrushLeach] int NULL,
    [ROM] int NULL,
    [UTC_CREATED_DATE] datetime NOT NULL
);