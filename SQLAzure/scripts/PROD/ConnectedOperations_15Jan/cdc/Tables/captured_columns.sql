CREATE TABLE [cdc].[captured_columns] (
    [object_id] int NOT NULL,
    [column_name] nvarchar(128) NOT NULL,
    [column_id] int NULL,
    [column_type] nvarchar(128) NOT NULL,
    [column_ordinal] int NOT NULL,
    [is_computed] bit NULL,
    [masking_function] nvarchar(4000) NULL
);