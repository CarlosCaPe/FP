CREATE TABLE [dbo].[Material_Delivered] (
    [siteflag] varchar(3) NOT NULL,
    [shiftid] varchar(10) NOT NULL,
    [truckid] varchar(10) NOT NULL,
    [TotalMaterialDelivered] int NULL,
    [UTC_CREATED_DATE] datetime NOT NULL
);