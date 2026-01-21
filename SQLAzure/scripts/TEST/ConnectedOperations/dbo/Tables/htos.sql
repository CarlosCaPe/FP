CREATE TABLE [dbo].[htos] (
    [SHIFTID] decimal(9,0) NOT NULL,
    [SHIFTINDEX] numeric(38,0) NOT NULL,
    [SITE_CODE] varchar(4) NOT NULL,
    [OPERATOR_ID] varchar(50) NOT NULL,
    [CREW] varchar(50) NOT NULL,
    [HTOSDATE] date NOT NULL,
    [Travel_Loaded_Score] numeric(18,5) NULL,
    [Travel_Empty_Score] numeric(18,5) NULL,
    [Shovel_Score] numeric(18,5) NULL,
    [Dump_Score] numeric(18,5) NULL,
    [Total_Score] numeric(18,5) NULL,
    [UTC_CREATED_DATE] datetime NULL
);