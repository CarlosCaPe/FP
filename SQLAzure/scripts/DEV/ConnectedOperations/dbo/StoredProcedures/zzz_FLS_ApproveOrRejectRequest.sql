







/******************************************************************  
* PROCEDURE	: dbo.FLS_ApproveOrRejectRequest
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 21 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.ApproveOrRejectRequest
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Apr 2023}		{sxavier}		{Initial Created} 
* {24 Apr 2023}		{ywibowo}		{Code review} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_ApproveOrRejectRequest] 
(	
	@IntegrationID UNIQUEIDENTIFIER,
	@Payload NVARCHAR(MAX),
	@Result NVARCHAR(MAX),
	@ApprovalStatus CHAR(1), -- 'A' is Approve, 'R' is Rejected
	@RequestID UNIQUEIDENTIFIER,
	@ActivityID UNIQUEIDENTIFIER,
	@ActionerID CHAR(10),
	@Comments VARCHAR(MAX)
)
AS                        
BEGIN    
	
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE
	@ApprovalActionedDate DATETIME,
	@SequenceID SMALLINT,
	@NextApprovalsJson NVARCHAR(MAX)

	SET @ApprovalActionedDate = (SELECT UtcCreatedDate FROM dbo.FLS_ViewIntegrations WHERE IntegrationID = @IntegrationID)
	SET @SequenceID = (SELECT SequenceID FROM dbo.FLS_ViewApprovals WHERE ActivityID = @ActivityID)

	SELECT
		@NextApprovalsJson = NextActivities
	FROM
		OPENJSON(@Result)
	WITH (
		NextActivities NVARCHAR(MAX) '$.nextActivities' AS JSON
	)

	BEGIN TRANSACTION

	-- Update approval item as approved or rejected.
	UPDATE
		dbo.FLS_Approvals
	SET
		ClosedByID = @ActionerID,
		Comments = @Comments,
		ApprovalStatus = @ApprovalStatus,
		ApprovalActionedDate = @ApprovalActionedDate,
		LastModifiedBy = @ActionerID,
		UtcLastModifiedDate = GETUTCDATE()
	WHERE
		ActivityID = @ActivityID
		AND ApprovalStatus = 'W'

	-- Update other approval items for the current sequence as canceled. 
	-- This is parallel approval process, either one approved or rejected, other approvals will be cancelled.
	UPDATE
		dbo.FLS_Approvals
	SET
		ClosedByID = @ActionerID,
		Comments = '',
		ApprovalStatus = 'C',
		ApprovalActionedDate = @ApprovalActionedDate,
		LastModifiedBy = @ActionerID,
		UtcLastModifiedDate = GETUTCDATE()
	WHERE
		RequestID = @RequestID
		AND SequenceID = @SequenceID
		AND ApprovalStatus = 'W'
		AND ActivityID <> @ActivityID

	-- Insert the next level approval if exists.
	INSERT INTO dbo.FLS_Approvals
	(
		ID,
		ActivityID,
		RequestID,
		SequenceID,
		ApproverAlias,
		ApproverID,
		ClosedByID,
		Comments,
		ApprovalStatus,
		ApprovalCreatedDate,
		ApprovalActionedDate,
		CreatedBy,
		UtcCreatedDate,
		LastModifiedBy,
		UtcLastModifiedDate
	)
	SELECT
		NEWID(),
		ActivityID,
		@RequestID,
		@SequenceID + 1,
		'',
		ApproverID,
		'',
		'',
		'W', -- W means Waiting for Approval
		@ApprovalActionedDate,
		@ApprovalActionedDate,
		@ActionerID,
		GETUTCDATE(),
		@ActionerID,
		GETUTCDATE()
	FROM 
		OPENJSON(@NextApprovalsJson)
	WITH (
		ActivityID UNIQUEIDENTIFIER '$.activityID',
		ApproverID CHAR(10) '$.assignedToID'
	)

	-- If there is no next approval, update request status to be approved or rejected.
	UPDATE
		dbo.FLS_Requests
	SET
		RequestStatus = CASE WHEN (@NextApprovalsJson IS NULL) THEN @ApprovalStatus ELSE RequestStatus END,
		RequestActionedDate = @ApprovalActionedDate,
		LastModifiedBy = @ActionerID,
		UtcLastModifiedDate = GETUTCDATE()
	WHERE
		RequestID = @RequestID

	COMMIT TRANSACTION

	SET NOCOUNT OFF

END

