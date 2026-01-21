CREATE TABLE [cli].[target_mine_by_shift_stg] (
    [Shiftid] varchar(15) NOT NULL,
    [PB] varchar(5) NULL,
    [Shovel] varchar(10) NULL,
    [HolesDrilled] int NULL,
    [FeetDrilled] int NULL,
    [TotalTonsMoved] int NULL,
    [TotalTonesMined] int NULL,
    [TotalMillOreMined] int NULL,
    [MillOreTonsMined] int NULL,
    [TotalTonstoCrusher] int NULL,
    [StockpileTons] int NULL,
    [WasteTons] int NULL,
    [EFH] int NULL,
    [UTC_CREATED_DATE] datetime NULL
);