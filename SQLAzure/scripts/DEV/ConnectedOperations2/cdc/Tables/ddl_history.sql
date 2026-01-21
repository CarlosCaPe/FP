CREATE TABLE [cdc].[ddl_history] (
    [source_object_id] int NULL,
    [object_id] int NOT NULL,
    [required_column_update] bit NULL,
    [ddl_command] nvarchar NULL,
    [ddl_lsn] binary(10) NOT NULL,
    [ddl_time] datetime NULL
);