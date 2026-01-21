CREATE TABLE [mor].[ZZZ_target_mine_by_shift_temp] (
    [ShiftId] varchar(15) NOT NULL,
    [ShovelId] varchar(5) NOT NULL,
    [PB] varchar(5) NULL,
    [Level] int NULL,
    [Destination] varchar(20) NOT NULL,
    [MaterialType] varchar(20) NOT NULL,
    [Tons] int NULL,
    [DTCU] float NULL,
    [Mo] float NULL,
    [EFH] int NULL,
    [UTC_CREATED_DATE] datetime NULL
);