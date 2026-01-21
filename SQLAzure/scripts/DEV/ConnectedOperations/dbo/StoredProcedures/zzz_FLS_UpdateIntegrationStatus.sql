










/******************************************************************  
* PROCEDURE	: dbo.FLS_UpdateIntegrationStatus
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 25 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_UpdateIntegrationStatus
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Apr 2023}		{sxavier}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_UpdateIntegrationStatus] 
(	
	@IntegrationID UNIQUEIDENTIFIER,
	@Payload NVARCHAR(MAX),
	@Result NVARCHAR(MAX),
	@Error NVARCHAR(MAX),
	@RetryNumber SMALLINT
)
AS                        
BEGIN    
	
	SET NOCOUNT ON
	SET XACT_ABORT ON

	IF(@Error = '')
	BEGIN
		-- Update integration step as done
		UPDATE
			dbo.FLS_Integrations
		SET
			Payload = @Payload,
			Result = @Result,
			Error = '',
			[Status] = 'D',
			RetryNumber = @RetryNumber,
			UtcLastModifiedDate = GETUTCDATE()
		WHERE
			IntegrationID = @IntegrationID
	END
	ELSE
	BEGIN
		-- Update integration step as failed
		UPDATE
			dbo.FLS_Integrations
		SET
			Payload = @Payload,
			Result = '',
			Error = @Error,
			[Status] = 'F',
			RetryNumber = @RetryNumber,
			UtcLastModifiedDate = GETUTCDATE()
		WHERE
			IntegrationID = @IntegrationID
	END

	SET NOCOUNT OFF

END

