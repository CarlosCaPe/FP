CREATE TABLE [dbo].[zzz_FLS_EmailTemplate] (
    [ID] char(4) NOT NULL,
    [MailSubject] varchar NOT NULL,
    [MailBody] varchar NOT NULL,
    [Description] varchar NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [LastModifiedBy] char(10) NOT NULL,
    [UtcLastModifiedDate] datetime NOT NULL
);