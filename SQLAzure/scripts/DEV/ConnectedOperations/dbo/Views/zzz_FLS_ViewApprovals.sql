CREATE VIEW [dbo].[zzz_FLS_ViewApprovals] AS






/******************************************************************  
* VIEW	    : dbo.FLS_ViewApprovals
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 17 Apr 2023
* SAMPLE	: 
	SELECT * FROM dbo.FLS_ViewApprovals
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Apr 2023}		{sxavier}		{Initial Created}
* {24 Apr 2023}		{ywibowo}		{Code review}

*******************************************************************/ 


CREATE VIEW [dbo].[FLS_ViewApprovals]
AS
	SELECT
		A.ID,
		A.ActivityID,
		GroupID = C.ID,
		A.RequestID,
		A.SequenceID,
		A.ApproverAlias,
		A.ApproverID,
		A.ClosedByID,
		A.Comments,
		C.RequestStatus,
		A.ApprovalStatus,
		ApprovalStatusDesc = b.[Value],
		A.ApprovalCreatedDate,
		A.ApprovalActionedDate
	FROM [dbo].[FLS_Approvals] A(NOLOCK)
		INNER JOIN [dbo].[FLS_LOOKUPS] B ON A.ApprovalStatus = B.TableCode
			AND B.TableType = 'APST'
		INNER JOIN [dbo].[FLS_Requests] C ON A.RequestId = C.RequestID
