CREATE TABLE [dbo].[systranschemas] (
    [tabid] int NOT NULL,
    [startlsn] binary(10) NOT NULL,
    [endlsn] binary(10) NOT NULL,
    [typeid] int NOT NULL DEFAULT ((52))
);