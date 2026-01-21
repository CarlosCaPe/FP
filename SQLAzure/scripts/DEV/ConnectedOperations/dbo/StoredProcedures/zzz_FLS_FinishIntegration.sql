









/******************************************************************  
* PROCEDURE	: dbo.FLS_FinishIntegration
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 21 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_FinishIntegration
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Apr 2023}		{sxavier}		{Initial Created} 
* {24 Apr 2023}		{ywibowo}		{Code review} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_FinishIntegration] 
(	
	@RequestID UNIQUEIDENTIFIER
)
AS                        
BEGIN    
	
	SET NOCOUNT ON
	SET XACT_ABORT ON

    --WAITFOR DELAY '00:00:05';

	-- Mark workflow integration as completed so that user can take another action.
	UPDATE
		dbo.FLS_Requests
	SET
		WorkflowIsInProgress = 0
	WHERE
		RequestID = @RequestID

	SET NOCOUNT OFF

END

