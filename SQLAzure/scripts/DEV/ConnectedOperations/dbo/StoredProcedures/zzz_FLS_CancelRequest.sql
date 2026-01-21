








/******************************************************************  
* PROCEDURE	: dbo.FLS_CancelRequest
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 21 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_CancelRequest
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Apr 2023}		{sxavier}		{Initial Created} 
* {24 Apr 2023}		{ywibowo}		{Code review} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_CancelRequest] 
(	
	@IntegrationID UNIQUEIDENTIFIER,
	@Payload NVARCHAR(MAX),
	@Result NVARCHAR(MAX),
	@RequestID UNIQUEIDENTIFIER,
	@CancelledByID CHAR(10),
	@Comments VARCHAR(MAX)
)
AS                        
BEGIN    
	
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE
	@ApprovalActionedDate DATETIME

	SET @ApprovalActionedDate = (SELECT UtcCreatedDate FROM dbo.FLS_ViewIntegrations WHERE IntegrationID = @IntegrationID)

	BEGIN TRANSACTION

	-- Update approval item as cancelled.
	UPDATE
		dbo.FLS_Approvals
	SET
		ClosedByID = @CancelledByID,
		Comments = '',
		ApprovalStatus = 'C',
		ApprovalActionedDate = @ApprovalActionedDate,
		LastModifiedBy = @CancelledByID,
		UtcLastModifiedDate = GETUTCDATE()
	WHERE
		RequestID = @RequestID
		AND ApprovalStatus = 'W'

	-- Update request status to be cancelled.
	UPDATE
		dbo.FLS_Requests
	SET
		RequestStatus = 'C',
		RequestActionedDate = @ApprovalActionedDate,
		LastModifiedBy = @CancelledByID,
		UtcLastModifiedDate = GETUTCDATE()
	WHERE
		RequestID = @RequestID

	-- Update integration step as done.
	--UPDATE
	--	dbo.FLS_Integrations
	--SET
	--	Payload = @Payload,
	--	Result = @Result,
	--	[Status] = 'D',
	--	UtcLastModifiedDate = GETUTCDATE()
	--WHERE
	--	IntegrationID = @IntegrationID
	
	COMMIT TRANSACTION

	SET NOCOUNT OFF

END

