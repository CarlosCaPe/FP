


/******************************************************************  
* PROCEDURE	: dbo.FLS_GetRequests
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 17 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_GetRequests NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Apr 2023}		{sxavier}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_GetRequests] 
(	
	@ID VARCHAR(36),
	@RequestID VARCHAR(36)
)
AS                        
BEGIN    
	
	SET NOCOUNT ON

	SELECT
		ID,
		RequestID,
		RequestedForID,
		RequestedByID,
		Comments,
		ApplicationStatus,
		WorkflowIsInProgress
	FROM 
		dbo.FLS_ViewRequests (NOLOCK)
	WHERE
		(@ID IS NULL OR ID = @ID)
		AND (@RequestID IS NULL OR RequestID = @RequestID)
	
	SET NOCOUNT OFF

END

