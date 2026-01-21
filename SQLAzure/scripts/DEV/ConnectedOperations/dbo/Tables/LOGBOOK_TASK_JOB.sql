CREATE TABLE [dbo].[LOGBOOK_TASK_JOB] (
    [Id] int NOT NULL,
    [LogbookId] int NOT NULL,
    [Status] varchar(1) NOT NULL,
    [Error] varchar NOT NULL,
    [Result] varchar NOT NULL,
    [Payload] varchar NOT NULL
);