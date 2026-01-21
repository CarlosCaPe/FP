CREATE TABLE [mor].[dispatch_mine_overview] (
    [ShiftId] decimal(19,0) NOT NULL,
    [ShovelId] varchar(36) NOT NULL,
    [NrOfDumps] int NULL,
    [TotalMineralsMined] int NULL,
    [TotalMaterialMined] int NULL,
    [RehandledOre] int NULL,
    [MillOreMined] int NULL,
    [ROMLeachMined] int NULL,
    [CrushedLeachMined] int NULL,
    [WasteMined] int NULL,
    [TotalMaterialDeliveredToCrusher] int NULL
);