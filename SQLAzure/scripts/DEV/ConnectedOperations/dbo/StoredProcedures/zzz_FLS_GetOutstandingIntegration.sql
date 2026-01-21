







/******************************************************************  
* PROCEDURE	: dbo.FLS_GetOutstandingIntegration
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 18 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_GetOutstandingIntegration 'F7FA0B76-B88A-4B17-AE73-D6A943E5E8D5'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {18 Apr 2023}		{sxavier}		{Initial Created} 
* {24 Apr 2023}		{ywibowo}		{Code review} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_GetOutstandingIntegration] 
(	
	@GroupID CHAR(36)
)
AS                        
BEGIN    
	
	SET NOCOUNT ON

	-- Get any outstanding integration steps. Status = O.
	SELECT
		IntegrationID,
		GroupID,
		SiteCode,
		ApprovalType,
		ApprovalSubType,
		ScreenParameter,
		IntegrationSequence,
		IntegrationType,
		Payload,
		Result,
		Error,
		[Status],
		RetryNumber
	FROM 
		dbo.FLS_ViewIntegrations (NOLOCK)
	WHERE
		GroupID = @GroupID
		AND [Status] = 'O'
	ORDER BY
		IntegrationSequence
	
	SET NOCOUNT OFF

END

