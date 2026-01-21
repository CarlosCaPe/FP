








/******************************************************************  
* PROCEDURE	: dbo.FLS_GetApproversTimeline
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 21 Apr 2023
* SAMPLE	: 
	EXEC dbo.[FLS_GetApproversTimeline] '8438807F-D03A-44FF-94D0-F758439FC0BF' -- Waiting for approval.
	EXEC dbo.[FLS_GetApproversTimeline] 'D743F44C-8112-48A3-8C91-84604634C062' -- Approved.
	EXEC dbo.[FLS_GetApproversTimeline] '95A01786-587C-47C0-874C-901862FF22F9' -- Rejected.
	EXEC dbo.[FLS_GetApproversTimeline] 'A6FF9BF3-A8C2-4995-BEC5-EEDA62F4D73D' -- Cancelled.

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Apr 2023}		{sxavier}		{Initial Created} 
* {24 Apr 2023}		{ywibowo}		{Code review} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_GetApproversTimeline] 
(	
	@GroupID UNIQUEIDENTIFIER
)
AS                        
BEGIN    

	SET NOCOUNT ON
	SET XACT_ABORT ON

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

	SET NOCOUNT OFF

END