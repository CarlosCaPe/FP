CREATE VIEW [dbo].[zzz_FLS_ViewRequests] AS






/******************************************************************  
* VIEW	    : dbo.FLS_ViewRequests
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 17 Apr 2023
* SAMPLE	: 
	1. SELECT * FROM dbo.FLS_ViewRequests
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Apr 2023}		{sxavier}		{Initial Created}
* {24 Apr 2023}		{ywibowo}		{Code review}
*******************************************************************/ 


CREATE VIEW [dbo].[FLS_ViewRequests]
AS
	SELECT
		A.ID,
		A.RequestID,
		A.SiteCode,
		A.ApprovalType,
		A.ApprovalSubType,
		A.RequestedForID,
		A.RequestedByID,
		A.Comments,
		A.RequestStatus,
		RequestStatusDesc = B.[Value],
		A.WorkflowIsInProgress,
		A.RequestCreatedDate,
		A.RequestActionedDate
	FROM [dbo].[FLS_Requests] A
		INNER JOIN [dbo].[FLS_LOOKUPS] B ON A.RequestStatus = B.TableCode
			AND B.TableType = 'RQST'

