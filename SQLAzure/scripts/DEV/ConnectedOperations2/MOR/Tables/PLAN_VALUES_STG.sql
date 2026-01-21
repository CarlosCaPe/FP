CREATE TABLE [MOR].[PLAN_VALUES_STG] (
    [CONTENTTYPEID] varchar(100) NOT NULL,
    [SHIFTID] varchar(50) NOT NULL,
    [COMPLIANCEASSETID] varchar(100) NULL,
    [SHOVEL] varchar(50) NOT NULL,
    [PB] varchar(50) NOT NULL,
    [DESTINATION] varchar(50) NOT NULL,
    [MATERIALTYPE] varchar(50) NOT NULL,
    [TONS] decimal(18,5) NOT NULL,
    [ID] int NOT NULL,
    [CONTENTTYPE] varchar(50) NOT NULL,
    [MODIFIED] datetime NOT NULL,
    [CREATED] datetime NOT NULL,
    [CREATEDBYID] int NOT NULL,
    [MODIFIEDBYID] int NOT NULL,
    [OWSHIDDENVERSION] int NOT NULL,
    [VERSION] decimal(18,5) NOT NULL,
    [PATH] varchar(2000) NOT NULL
);