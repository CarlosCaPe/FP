





/******************************************************************  
* PROCEDURE	: dbo.FLS_UpdateIntegrations
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 17 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_UpdateIntegrations '76CA9C12-11A3-47C3-A5DD-BB658DA63CF1', '65KA6412-11A3-47C3-A5DD-2F658DA63CF1', 'Screen 2', 2, 'Type 2',
		'Payload 2', 'Result 2', 'No Error', 'Approved', 3, '0000000002'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Apr 2023}		{sxavier}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_UpdateIntegrations] 
(	
	@ActivityID CHAR(36),
	@GroupID CHAR(36),
	@ScreenParameter VARCHAR(MAX),
	@IntegrationSequence INT,
	@IntegrationType VARCHAR(64),
	@Payload VARCHAR(MAX),
	@Result VARCHAR(MAX),
	@Error VARCHAR(MAX),
	@Status VARCHAR(64),
	@RetryNumber INT,
	@ModifiedBy CHAR(10)
)
AS                        
BEGIN    
	
	SET NOCOUNT ON
	
	UPDATE 
		dbo.FLS_Integrations
	SET
		GroupID = @GroupID,
		ScreenParameter = @ScreenParameter,
		IntegrationSequence = @IntegrationSequence,
		IntegrationType = @IntegrationType,
		Payload = @Payload,
		Result = @Result,
		Error = @Error,
		[Status] = @Status,
		RetryNumber = @RetryNumber,
		LastModifiedBy = @ModifiedBy,
		UtcLastModifiedDate = GETUTCDATE()
	WHERE
		ActivityID = @ActivityID

	SET NOCOUNT OFF

END

