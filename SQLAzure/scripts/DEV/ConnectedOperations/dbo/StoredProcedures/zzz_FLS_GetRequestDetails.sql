








/******************************************************************  
* PROCEDURE	: dbo.FLS_GetApproversTimeline
* PURPOSE	: 
* NOTES		: 
* CREATED	: ywibowo, 24 Apr 2023
* SAMPLE	: 
	EXEC dbo.[FLS_GetRequestDetails] 'CCF68DAD-AA17-4E24-AB49-3EC73BF65035'


* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {24 Apr 2023}		{ywibowo}		{Initial code} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_GetRequestDetails] 
(	
	@RequestID UNIQUEIDENTIFIER
)
AS                        
BEGIN    

	SET NOCOUNT ON
	SET XACT_ABORT ON

	SELECT 
		[GroupID] = A.ID,
		[RequestID] = A.RequestID,
		[RequestedForID] = A.RequestedForID,
		[RequestedByID] = A.RequestedByID,
		[RequestCreatedDate] = A.RequestCreatedDate,
		[RequestActionedDate] = A.RequestActionedDate,
		[RequestStatus] = A.RequestStatus,
		[RequestStatusDesc] = A.RequestStatusDesc,
		[ActivityID] = B.ActivityID,
		[ApproverID] = B.ApproverID,
		[ClosedByID] = B.ClosedByID,
		[Comments] = B.Comments,
		[SequenceID] = B.SequenceID,
		[ApprovalStatus] = B.ApprovalStatus,
		[ApprovalStatusDesc] = B.ApprovalStatusDesc,
		[ApprovalCreatedDate] = B.ApprovalCreatedDate,
		[ApprovalActionedDate] = B.ApprovalActionedDate
	FROM
		dbo.FLS_ViewRequests A
		JOIN dbo.FLS_ViewApprovals B ON A.RequestID = B.RequestID
	WHERE
		A.RequestID = @RequestID

	SET NOCOUNT OFF

END