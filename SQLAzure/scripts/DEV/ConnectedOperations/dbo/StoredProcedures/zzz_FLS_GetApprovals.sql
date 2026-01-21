



/******************************************************************  
* PROCEDURE	: dbo.FLS_GetApprovals
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 17 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_GetApprovals NULL, NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Apr 2023}		{sxavier}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_GetApprovals] 
(	
	@ID VARCHAR(36),
	@ActivityID VARCHAR(36),
	@RequestID VARCHAR(36)
)
AS                        
BEGIN    
	
	SET NOCOUNT ON

	SELECT
		ID,
		ActivityID,
		RequestID,
		SequenceID,
		ApproverAlias,
		ApproverID,
		ClosedByID,
		Comments,
		ApplicationStatus
	FROM 
		dbo.FLS_ViewApprovals (NOLOCK)
	WHERE
		(@ID IS NULL OR ID = @ID)
		AND (@ActivityID IS NULL OR ActivityID = @ActivityID)
		AND (@RequestID IS NULL OR RequestID = @RequestID)
	
	SET NOCOUNT OFF

END

