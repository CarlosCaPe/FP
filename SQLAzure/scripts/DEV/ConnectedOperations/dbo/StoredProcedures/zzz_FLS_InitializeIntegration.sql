







/******************************************************************  
* PROCEDURE	: dbo.FLS_StartIntegration
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 21 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_StartIntegration
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
*---------------------------------------------------------------------------------------------  
* {21 Apr 2023}		{sxavier}		{Initial Created} 
* {24 Apr 2023}		{ywibowo}		{Code review} 
* {27 Apr 2023}		{pananda}		{Add request status checks when requestID is not null}
**********************************************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_InitializeIntegration] 
(	
	@ScreenParameter VARCHAR(MAX),
	@JsonText NVARCHAR(MAX) -- Contains request ID and list of integrations
)
AS                        
BEGIN    
	
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE
	@RequestID UNIQUEIDENTIFIER,
	@GroupID UNIQUEIDENTIFIER,
	@CreatedBy CHAR(10),
	@IntegrationsJson NVARCHAR(MAX),
	@SiteCode VARCHAR(10),
	@ApprovalType CHAR(4),
	@ApprovalSubType VARCHAR(16)

	SELECT
		@SiteCode = SiteCode,
		@ApprovalType = ApprovalType,
		@ApprovalSubType = ISNULL(ApprovalSubType, '')
	FROM
		OPENJSON(@ScreenParameter)
	WITH (
		SiteCode VARCHAR(10) '$.siteCode',
		ApprovalType CHAR(4) '$.approvalType',
		ApprovalSubType VARCHAR(16) '$.approvalSubType'
	)

	SELECT
		@RequestID = RequestID,
		@CreatedBy = CreatedBy,
		@IntegrationsJson = Integrations
	FROM 
		OPENJSON(@JsonText) 
	WITH (
		RequestID UNIQUEIDENTIFIER '$.requestID',
		CreatedBy CHAR(10) '$.createdBy',
		Integrations NVARCHAR(MAX) '$.integrations' AS JSON
	)

	BEGIN TRANSACTION

		-- If requestID is null then this is new request.
		IF(@RequestID IS NULL)
		BEGIN
			
			-- If there is outstanding integration or active request for the current SiteCode, ApprovalType, and ApprovalSubType, then do nothing.
			IF (
				NOT EXISTS (SELECT 1 FROM dbo.FLS_ViewRequests WHERE SiteCode = @SiteCode AND ApprovalType = @ApprovalType AND ApprovalSubType = @ApprovalSubType AND RequestStatus = 'W')
				AND NOT EXISTS (SELECT 1 FROM dbo.FLS_ViewIntegrations WHERE SiteCode = @SiteCode AND ApprovalType = @ApprovalType AND ApprovalSubType = @ApprovalSubType AND IntegrationType = 'ReportIntegration_SubmitWorkflowRequestTask' AND Status = 'O')
			)
			BEGIN
				SET @GroupID = NEWID()

				INSERT INTO dbo.FLS_Integrations
				(
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
					RetryNumber,
					CreatedBy,
					UtcCreatedDate,
					LastModifiedBy,
					UtcLastModifiedDate
				)
				SELECT
					NEWID(),
					@GroupID,
					@SiteCode,
					@ApprovalType,
					@ApprovalSubType,
					@ScreenParameter,
					[IntegrationSequence],
					[IntegrationType],
					'',
					'',
					'',
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

				-- Return GroupID to be passed into event hub.
				SELECT @GroupID AS GroupID
			END

		END
		ELSE
		BEGIN
			-- If requestID is not null then we need to check if integration process is running or not OR if request is already actioned. 
			-- If W