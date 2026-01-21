CREATE TABLE [cdc].[change_tables] (
    [object_id] int NOT NULL,
    [version] int NULL,
    [source_object_id] int NULL,
    [capture_instance] nvarchar(128) NOT NULL,
    [start_lsn] binary(10) NULL,
    [end_lsn] binary(10) NULL,
    [supports_net_changes] bit NULL,
    [has_drop_pending] bit NULL,
    [role_name] nvarchar(128) NULL,
    [index_name] nvarchar(128) NULL,
    [filegroup_name] nvarchar(128) NULL,
    [create_date] datetime NULL,
    [partition_switch] bit NOT NULL DEFAULT ((0))
);