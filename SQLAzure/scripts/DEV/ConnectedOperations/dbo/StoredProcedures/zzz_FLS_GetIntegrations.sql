





/******************************************************************  
* PROCEDURE	: dbo.FLS_GetIntegrations
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 17 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_GetIntegrations NULL, NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Apr 2023}		{sxavier}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_GetIntegrations] 
(	
	@ActivityID CHAR(36),
	@GroupID CHAR(36),
	@IntegrationType VARCHAR(64)
)
AS                        
BEGIN    
	
	SET NOCOUNT ON

	SELECT
		ActivityID,
		GroupID,
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
		(@ActivityID IS NULL OR ActivityID = @ActivityID)
		AND (@GroupID IS NULL OR GroupID = @GroupID)
		AND (@IntegrationType IS NULL OR IntegrationType = @IntegrationType)
	
	SET NOCOUNT OFF

END

