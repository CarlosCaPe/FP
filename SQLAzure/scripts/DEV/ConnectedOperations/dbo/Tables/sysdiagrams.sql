CREATE TABLE [dbo].[sysdiagrams] (
    [name] nvarchar(128) NOT NULL,
    [principal_id] int NOT NULL,
    [diagram_id] int NOT NULL,
    [version] int NULL,
    [definition] varbinary NULL
);