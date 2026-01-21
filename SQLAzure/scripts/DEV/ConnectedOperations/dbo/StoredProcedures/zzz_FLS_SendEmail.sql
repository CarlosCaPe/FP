







/******************************************************************  
* PROCEDURE	: dbo.[FLS_SendEmail]
* PURPOSE	: 
* NOTES		: 
* CREATED	: ywibowo, 24 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.[FLS_SendEmail]
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {24 Apr 2023}		{ywibowo}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_SendEmail] 
(	
	@IntegrationID UNIQUEIDENTIFIER,
	@Payload NVARCHAR(MAX),
	@Result NVARCHAR(MAX)
)
AS                        
BEGIN    
	
	SET NOCOUNT ON
	SET XACT_ABORT ON

	BEGIN TRANSACTION

	-- Update integration step as done
	UPDATE
		dbo.FLS_Integrations
	SET
		Payload = @Payload,
		Result = @Result,
		[Status] = 'D',
		UtcLastModifiedDate = GETUTCDATE()
	WHERE
		IntegrationID = @IntegrationID

	COMMIT TRANSACTION

	SET NOCOUNT OFF

END

