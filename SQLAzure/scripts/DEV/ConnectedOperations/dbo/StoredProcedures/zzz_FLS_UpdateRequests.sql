



/******************************************************************  
* PROCEDURE	: dbo.FLS_UpdateRequests
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 17 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_UpdateRequests '22DBD099-E121-4B35-85BD-94F245DF658E', 'F09B90A2-BF48-41D1-B475-4F1CA094712B',
		'0000000004', '0000000004', 'Comment 4', 'Running', 0, '0000000004'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Apr 2023}		{sxavier}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_UpdateRequests] 
(	
	@ID VARCHAR(36),
	@RequestID VARCHAR(36),
	@RequestedForID CHAR(10),
	@RequestedByID CHAR(10),
	@Comments VARCHAR(MAX),
	@ApplicationStatus VARCHAR(16),
	@WorkflowIsInProgress BIT,
	@ModifiedBy CHAR(10)
)
AS                        
BEGIN    
	
	SET NOCOUNT ON
	
	UPDATE 
		dbo.FLS_Requests
	SET
		RequestID = @RequestID,
		RequestedForID = @RequestedForID,
		RequestedByID = @RequestedByID,
		Comments = @Comments,
		ApplicationStatus = @ApplicationStatus,
		WorkflowIsInProgress = @WorkflowIsInProgress,
		LastModifiedBy = @ModifiedBy,
		UtcLastModifiedDate = GETUTCDATE()
	WHERE
		ID = @ID

	SET NOCOUNT OFF

END

