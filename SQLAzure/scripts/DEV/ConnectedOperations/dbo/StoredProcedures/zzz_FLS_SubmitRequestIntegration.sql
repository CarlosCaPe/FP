







/******************************************************************  
* PROCEDURE	: dbo.FLS_SubmitRequestIntegration
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 18 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_SubmitRequestIntegration
		'{"approvers": ["0000000001", "0000000002"], "requestedById": "0000000001", "requestedForId": "0000000001"}',
		'
			{
				"createdBy": "0000000001",
				"integrations": [
					{
						"sequence": 0,
						"type": "CreateWorkflowRequest"
					},
					{
						"sequence": 1,
						"type": "UpdateDatabaseProductionAccounting"
					},
					{
						"sequence": 2,
						"type": "SendEmailNotification"
					}
				]
			}
		'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {18 Apr 2023}		{sxavier}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_SubmitRequestIntegration] 
(	
	@ScreenParameter VARCHAR(MAX),
	@JsonText NVARCHAR(MAX)
)
AS                        
BEGIN    
	
	SET NOCOUNT ON
	SET XACT_ABORT ON

	BEGIN TRANSACTION

		DECLARE
		@GroupID UNIQUEIDENTIFIER,
		@CreatedBy CHAR(10),
		@IntegrationsJson NVARCHAR(MAX)

		SET @GroupID = NEWID()

		SELECT 
			@CreatedBy = CreatedBy,
			@IntegrationsJson = Integrations
		FROM 
			OPENJSON(@JsonText)
		WITH (
			CreatedBy CHAR(10) '$.createdBy',
			Integrations NVARCHAR(MAX) '$.integrations' AS JSON
		)

		INSERT INTO dbo.FLS_Integrations
		(
			IntegrationID,
			GroupID,
			ScreenParameter,
			IntegrationSequence,
			IntegrationType,
			[Status],
			RetryNumber,
			CreatedBy,
			UtcCreatedDate,
			LastModifiedBy,
			UtcLastModifiedDate
		)
		SELECT
			NEWID(),
			@GroupID,
			@ScreenParameter,
			[IntegrationSequence],
			[IntegrationType],
			'O', -- Outstanding status
			0,
			@CreatedBy,
			GETUTCDATE(),
			@CreatedBy,
			GETUTCDATE()
		FROM
			OPENJSON(@IntegrationsJson)
		WITH (
			[IntegrationSequence] INT '$.sequence',
			[IntegrationType] VARCHAR(64) '$.type'
		);

		-- Return GroupID
		SELECT @GroupID AS GroupID

	COMMIT TRANSACTION

	SET NOCOUNT OFF

END

