CREATE TABLE [dbo].[zzz_FLS_Requests] (
    [ID] uniqueidentifier NOT NULL,
    [RequestID] uniqueidentifier NOT NULL,
    [SiteCode] varchar(10) NOT NULL,
    [ApprovalType] char(4) NOT NULL,
    [ApprovalSubType] varchar(16) NOT NULL,
    [RequestedForID] char(10) NOT NULL,
    [RequestedByID] char(10) NOT NULL,
    [Comments] varchar NOT NULL,
    [RequestStatus] char(1) NOT NULL,
    [WorkflowIsInProgress] bit NOT NULL,
    [RequestCreatedDate] datetime NOT NULL,
    [RequestActionedDate] datetime NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [LastModifiedBy] char(10) NOT NULL,
    [UtcLastModifiedDate] datetime NOT NULL
);