CREATE TYPE [dbo].[LogbookListNew] AS TABLE (
    [Id] int NOT NULL,
    [ShiftId] varchar(16) NOT NULL,
    [Title] nvarchar(512) NOT NULL,
    [Description] nvarchar(MAX) NOT NULL,
    [Importance] varchar(8) NOT NULL,
    [Area] varchar(8) NOT NULL,
    [AsigneeEmployeeId] char(10) NULL,
    [ExtendedProperty1] nvarchar(512) NULL,
    [ExtendedProperty2] nvarchar(512) NULL,
    [ExtendedProperty3] nvarchar(512) NULL,
    [ExtendedProperties] nvarchar(MAX) NULL,
    [AssignTo] char(10) NULL,
    [DueDate] datetime NULL,
    [TaskAreaCode] varchar(8) NULL
);