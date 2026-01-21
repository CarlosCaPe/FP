CREATE TYPE [dbo].[udTT_TruckStatusEquipmentTemp] AS TABLE (
    [EquipmentName] varchar(8) NOT NULL,
    [EquipmentType] varchar(16) NOT NULL,
    [StartDateTime] datetime2 NULL,
    [EndDateTime] datetime2 NULL,
    [TimeInState] int NULL,
    [Description1] int NULL,
    [Description2] varchar(64) NULL,
    [Status] varchar(16) NULL,
    [CurrentStatus] varchar(16) NULL,
    [DeltaC] decimal(18,6) NULL,
    [AvePL] decimal(18,12) NULL,
    [OperatorName] nvarchar(64) NULL,
    [UseOfAvailability] decimal(18,6) NULL,
    [Autonomous] bit NULL
);