


/******************************************************************  
* PROCEDURE	: dbo.FLS_InsertRequests
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 17 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_InsertRequests '08CA9C12-B1A3-47C3-A5DD-2F658DA63CF1', '165A9CC9-B1A3-47C3-A5DD-2F658DA63CF1'
		'0000000003', '0000000003', 'Comment 1', 'Running', 1, '0000000003'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Apr 2023}		{sxavier}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_InsertRequests] 
(	
	@ID VARCHAR(36),
	@RequestID VARCHAR(36),
	@RequestedForID CHAR(10),
	@RequestedByID CHAR(10),
	@Comments VARCHAR(MAX),
	@ApplicationStatus VARCHAR(16),
	@WorkflowIsInProgress BIT,
	@CreatedBy CHAR(10)
)
AS                        
BEGIN    
	
	SET NOCOUNT ON

	INSERT INTO dbo.FLS_Requests
	(
		ID,
		RequestID,
		RequestedForID,
		RequestedByID,
		Comments,
		ApplicationStatus,
		WorkflowIsInProgress,
		CreatedBy,
		UtcCreatedDate,
		LastModifiedBy,
		UtcLastModifiedDate
	)
	VALUES
	(
		@ID,
		@RequestID,
		@RequestedForID,
		@RequestedByID,
		@Comments,
		@ApplicationStatus,
		@WorkflowIsInProgress,
		@CreatedBy,
		GETUTCDATE(),
		@CreatedBy,
		GETUTCDATE()
	)
		
	SET NOCOUNT OFF

END

