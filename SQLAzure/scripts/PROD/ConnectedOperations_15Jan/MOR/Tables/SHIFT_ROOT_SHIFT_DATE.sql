CREATE TABLE [MOR].[SHIFT_ROOT_SHIFT_DATE] (
    [siteflag] varchar(5) NOT NULL,
    [Id] decimal(19,0) NOT NULL,
    [FieldStart] int NULL,
    [FieldTime] int NULL,
    [FieldYear] int NULL,
    [FieldMonth] decimal(19,0) NULL,
    [FieldDay] int NULL,
    [FieldShift] decimal(19,0) NULL,
    [FieldCrew] decimal(19,0) NULL,
    [FieldHoliday] int NULL,
    [FieldUtcstart] int NULL,
    [FieldUtcend] int NULL,
    [FieldDststate] decimal(19,0) NULL,
    [UTC_CREATED_DATE] datetime NOT NULL,
    [UTC_LOGICAL_DELETED_DATE] datetime NULL
);