



/******************************************************************  
* PROCEDURE	: dbo.FLS_SubmitRequest
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 18 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_SubmitRequest '44479477-70D8-48A2-BF6B-83EC5A732796', '44479477-70D8-48A2-BF6B-83EC5A732796',
		'{
			"application": "string",
			"requestedForID": "0000000002",
			"requestedByID": "0000000002",
			"summary": "no summary",
			"applicationStatus": "Running",
			"requestUrl": "string",
			"activities": [
				{
					"type": "Unknown",
					"assignedToID": "0000000005",
					"applicationStatus": "Running",
					"activityUrl": "string"
				}
			]
		}',
		'{
			"requestID": "FCC027F6-031A-4207-BE73-44F23A671C1E",
			"activities": [
				{
					"activityID": "D7A9F668-27D1-43E2-986B-ED7474D47C8A",
					"type": "string",
					"assignedToID": "0000000005",
					"applicationStatus": "Run"
				},
				{
					"activityID": "2846AC8B-25DF-4FD0-AD6C-67A372CAEDB6",
					"type": "string",
					"assignedToID": "0000000003",
					"applicationStatus": "Stop"
				}
			]
		}'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*----------------------------------------------------------------------------------
* {18 Apr 2023}		{sxavier}		{Initial Created} 
* {21 Apr 2023}		{sxavier}		{Adjust logic} 
* {24 Apr 2023}		{ywibowo}		{Code review} 
* {27 Apr 2023}     {pananda}       {Hardcode request & approval status as 'W'}
***********************************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_SubmitRequest] 
(	
	@SiteCode VARCHAR(10),
	@ApprovalType CHAR(4),
	@ApprovalSubType VARCHAR(16) = '',
	@GroupID UNIQUEIDENTIFIER,
	@IntegrationID UNIQUEIDENTIFIER,
	@Payload NVARCHAR(MAX),
	@Result NVARCHAR(MAX)
)
AS                        
BEGIN    
	
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE
	@RequestID UNIQUEIDENTIFIER,
	@RequestedForID CHAR(10),
	@RequestedByID CHAR(10),
	@Comments VARCHAR(MAX),
	--@RequestStatus VARCHAR(16), 
	@ApprovalsJson NVARCHAR(MAX),
	@RequestCreatedDate DATETIME
	--@ApproverAlias VARCHAR(MAX)

	--Get all variables for request and approvals.
	SET @RequestCreatedDate = (SELECT UtcCreatedDate FROM dbo.FLS_ViewIntegrations WHERE IntegrationID = @IntegrationID)
	--SET @ApproverAlias = (SELECT [Value] FROM FLS_ViewLookups WHERE TableType = 'APTL' AND TableCode = '0' AND TableExtension = 'EN')

	SELECT
		@RequestedForID = RequestedForID,
		@RequestedByID = RequestedByID,
		@Comments = ISNULL(Comments, '')
		--@RequestStatus = RequestStatus
	FROM 
		OPENJSON(@Payload)
	WITH (
		RequestedForID CHAR(10) '$.requestedForID',
		RequestedByID CHAR(10) '$.requestedByID',
		Comments VARCHAR(MAX) '$.comments'
		--RequestStatus VARCHAR(16) '$.applicationStatus' --value = W
	)

	SELECT
		@RequestID = RequestID,
		@ApprovalsJson = Activities
	FROM 
		OPENJSON(@Result)
	WITH (
		RequestID UNIQUEIDENTIFIER '$.requestID',
		Activities NVARCHAR(MAX) '$.activities' AS JSON
	)

	BEGIN TRANSACTION
		-- Create new request.
		INSERT INTO dbo.FLS_Requests
		(
			ID,
			RequestID,
			SiteCode,
			ApprovalType,
			ApprovalSubType,
			RequestedForID,
			RequestedByID,
			Comments,
			RequestStatus,
			WorkflowIsInProgress,
			RequestCreatedDate,
			RequestActionedDate,
			CreatedBy,
			UtcCreatedDate,
			LastModifiedBy,
			UtcLastModifiedDate
		)
		VALUES
		(
			@GroupID,
			@RequestID,
			@SiteCode,
			@ApprovalType,
			@ApprovalSubType,
			@RequestedForID,
			@RequestedByID,
			@Comments,
			'W', -- W means Waiting for Approval
			1, -- 1 means integration process is running
			@RequestCreatedDate,
			@RequestCreatedDate,
			@RequestedByID,
			GETUTCDATE(),
			@RequestedByID,
			GETUTCDATE()
		)

		-- Create new approvals.
		INSERT INTO dbo.FLS_Approvals
		(
			ID,
			ActivityID,
			RequestID,
			SequenceID,
			ApproverAlias,
			ApproverID,
			ClosedByID,
			Comments,
			Approva