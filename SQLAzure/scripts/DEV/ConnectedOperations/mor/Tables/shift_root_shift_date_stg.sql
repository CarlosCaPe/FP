CREATE TABLE [mor].[shift_root_shift_date_stg] (
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
    [change_type] varchar(1) NOT NULL,
    [change_id] decimal(19,0) NOT NULL,
    [UTC_CREATED_DATE] datetime NOT NULL,
    [UTC_LOGICAL_DELETED_DATE] datetime NULL
);