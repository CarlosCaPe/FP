







/******************************************************************  
* PROCEDURE	: dbo.FLS_GetApprovalFlow
* PURPOSE	: 
* NOTES		: 
* CREATED	: pananda, 9 May 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_GetApprovalFlow
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {9 May 2023}		{pananda}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_GetApprovalFlow]
(
	@SiteCode VARCHAR(10),
	@ApprovalType CHAR(4),
	@ApprovalSubType VARCHAR(16) = '',
	@GroupID UNIQUEIDENTIFIER
)
AS                        
BEGIN    
	
	SET NOCOUNT ON

	IF (@GroupID IS NULL)
	BEGIN

		SET @ApprovalSubType = ISNULL(@ApprovalSubType, '');
	
		-- Select group ID from latest active submit request integration (Status = 'O')
		SELECT TOP 1
			@GroupID = GroupID
		FROM
			dbo.FLS_ViewIntegrations (NOLOCK)
		WHERE
			SiteCode = @SiteCode
			AND ApprovalType = @ApprovalType
			AND ApprovalSubType = @ApprovalSubType
			AND IntegrationType = 'ReportIntegration_SubmitWorkflowRequestTask'
			AND Status = 'O'
		ORDER BY UtcCreatedDate DESC

		-- If there is no outstanding integration, select group ID from latest active requests (RequestStatus = 'W')
		IF (@GroupID IS NULL)
		BEGIN
			SELECT TOP 1
				@GroupID = ID
			FROM 
				dbo.FLS_ViewRequests (NOLOCK) 
			WHERE 
				SiteCode = @SiteCode
				AND ApprovalType = @ApprovalType
				AND ApprovalSubType = @ApprovalSubType
				AND RequestStatus = 'W'
			ORDER BY RequestCreatedDate DESC
		END
	END

	IF (@GroupID IS NOT NULL)
	BEGIN
		SELECT 
			[Type] = 'R',			-- Differentiate between request and approval.
			[RequestID] = A.RequestID,
			[ActivityID] = NULL,
			--[Alias] = '',				-- No alias for requestor.
			[EmployeeID] = A.RequestedForID,
			[ActionerID] =  '',
			[Comments] = A.Comments,
			[Sequence] = 0,
			[Status] = 'S',
			[StatusDesc] = (SELECT [Value] FROM dbo.FLS_Lookups WHERE TableType = 'RQST' AND TableCode = 'S'),
			[ActionedDate] = A.RequestCreatedDate,
			[OverallRequestStatus] = A.RequestStatus,
			[OverallRequestStatusDesc] = B.[Value],
			[OverallRequestActionedDate] = A.RequestActionedDate,
			[WorkflowIsInProgress] = A.WorkflowIsInProgress
		FROM
			dbo.FLS_ViewRequests A
			JOIN dbo.FLS_ViewLookups B ON B.TableType = 'RQST' AND B.TableCode = A.RequestStatus
		WHERE
			A.ID = @GroupID
		UNION ALL
		SELECT 
			[Type] = 'A',
			[RequestID] = B.RequestID,
			[ActivityID] = B.ActivityID,
			--[Alias] = B.ApproverAlias,
			[EmployeeID] = B.ApproverID,
			[ActionerID] = B.ClosedByID,
			[Comments] = B.Comments,
			[Sequence] = B.SequenceID,
			[Status] = B.ApprovalStatus,
			[StatusDesc] = B.ApprovalStatusDesc,
			-- If approval is still penting then get submitted date elase get actioned date.
			[ActionedDate] = CASE WHEN B.ApprovalStatus = 'W' THEN B.ApprovalCreatedDate ELSE B.ApprovalActionedDate END,
			[OverallRequestStatus] = A.RequestStatus,
			[OverallRequestStatusDesc] = C.[Value],
			[OverallRequestActionedDate] = A.RequestActionedDate,
			[WorkflowIsInProgress] = A.WorkflowIsInProgress
		FROM
			dbo.FLS_ViewRequests A
			JOIN dbo.FLS_ViewApprovals B ON A.RequestID = B.RequestID
			JOIN dbo.FLS_ViewLookups C ON C.TableType = 'RQST' AND C.TableCode = A.RequestStatus
		WHERE
			A.ID = @GroupID
		UNION ALL
		SELECT 
			[Type] = 'A',
			[RequestID] = NULL,
			[ActivityID] = NULL,
			--[Alias] = B.ApproverAlias,
			[EmployeeID] = [Value],
			[ActionerID] = '',
			[Comments] = '',
			[Sequence] = CAST(TableCode as INT),
			[Status] = '',
			[StatusDesc] = '',
			-- If approval is still penting then get submitted date elase get actioned date.
			[ActionedDate] = NULL,
			[OverallRequestStatus] = '',
			[OverallRequestStatusDesc] = '',
			[OverallRequestActionedDate] = NULL,
			[WorkflowIsInProgress] = 0
		FROM 
			dbo.FLS_ViewLookups (NOLOCK