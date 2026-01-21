CREATE TABLE [cdc].[index_columns] (
    [object_id] int NOT NULL,
    [column_name] nvarchar(128) NOT NULL,
    [index_ordinal] tinyint NOT NULL,
    [column_id] int NOT NULL
);