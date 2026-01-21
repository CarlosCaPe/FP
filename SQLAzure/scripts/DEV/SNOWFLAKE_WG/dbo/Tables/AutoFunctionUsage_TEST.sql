CREATE TABLE [dbo].[AutoFunctionUsage_TEST] (
    [Site] nvarchar(50) NOT NULL,
    [SerialNumber] nvarchar(100) NOT NULL,
    [RigName] nvarchar(100) NULL,
    [OperatorName] nvarchar(100) NULL,
    [DrillPlanId] nvarchar(100) NOT NULL,
    [DrillPlanName] nvarchar(200) NOT NULL,
    [HoleId] nvarchar(100) NOT NULL,
    [HoleName] nvarchar(200) NULL,
    [StartHoleTime] datetime NOT NULL,
    [DrillStateSeconds] int NULL,
    [AutoDrillSeconds] int NULL,
    [SetupStateSeconds] int NULL,
    [AutoLevelSeconds] int NULL,
    [AutoDelevelSeconds] int NULL
);