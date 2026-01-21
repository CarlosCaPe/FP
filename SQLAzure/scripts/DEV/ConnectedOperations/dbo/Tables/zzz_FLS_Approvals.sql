CREATE TABLE [dbo].[zzz_FLS_Approvals] (
    [ID] uniqueidentifier NOT NULL,
    [ActivityID] uniqueidentifier NOT NULL,
    [RequestID] uniqueidentifier NOT NULL,
    [SequenceID] smallint NOT NULL,
    [ApproverAlias] varchar(64) NOT NULL,
    [ApproverID] char(10) NOT NULL,
    [ClosedByID] char(10) NOT NULL,
    [Comments] varchar NOT NULL,
    [ApprovalStatus] char(1) NOT NULL,
    [ApprovalCreatedDate] datetime NOT NULL,
    [ApprovalActionedDate] datetime NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [LastModifiedBy] char(10) NOT NULL,
    [UtcLastModifiedDate] datetime NOT NULL
);