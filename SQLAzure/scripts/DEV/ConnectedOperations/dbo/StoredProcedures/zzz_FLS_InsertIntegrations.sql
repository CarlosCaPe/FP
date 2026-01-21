




/******************************************************************  
* PROCEDURE	: dbo.FLS_InsertIntegrations
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 17 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_InsertIntegrations '76CA9C12-11A3-47C3-A5DD-2F658DA63CF1', '65KA9C12-11A3-47C3-A5DD-2F658DA63CF1', 'Screen 1', 1, 'Type 1',
		'Payload 1', 'Result 1', 'No Error', 'Approved', 2, '0000000002'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Apr 2023}		{sxavier}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_InsertIntegrations] 
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
	@CreatedBy CHAR(10)
)
AS                        
BEGIN    
	
	SET NOCOUNT ON

	INSERT INTO dbo.FLS_Integrations
	(
		ActivityID,
		GroupID,
		ScreenParameter,
		IntegrationSequence,
		IntegrationType,
		Payload,
		Result,
		Error,
		[Status],
		RetryNumber,
		CreatedBy,
		UtcCreatedDate,
		LastModifiedBy,
		UtcLastModifiedDate
	)
	VALUES
	(
		@ActivityID,
		@GroupID,
		@ScreenParameter,
		@IntegrationSequence,
		@IntegrationType,
		@Payload,
		@Result,
		@Error,
		@Status,
		@RetryNumber,
		@CreatedBy,
		GETUTCDATE(),
		@CreatedBy,
		GETUTCDATE()
	)
		
	SET NOCOUNT OFF

END

