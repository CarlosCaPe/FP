CREATE TABLE [mor].[mined_by_shift_target] (
    [ShiftId] varchar(15) NOT NULL,
    [ShovelId] varchar(5) NOT NULL,
    [PB] varchar(5) NULL,
    [Level] int NULL,
    [Destination] varchar(20) NULL,
    [MaterialType] varchar(20) NOT NULL,
    [Tons] int NULL,
    [DTCU] float NULL,
    [Mo] float NULL,
    [EFH] int NULL
);