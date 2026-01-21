CREATE VIEW [dbo].[zzz_FLS_ViewIntegrations] AS





/******************************************************************  
* VIEW	    : dbo.FLS_ViewIntegrations
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 17 Apr 2023
* SAMPLE	: 
	SELECT * FROM dbo.FLS_ViewIntegrations
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Apr 2023}		{sxavier}		{Initial Created}
* {24 Apr 2023}		{ywibowo}		{Code review.}
*******************************************************************/ 


CREATE VIEW [dbo].[FLS_ViewIntegrations]
AS
	SELECT
		A.IntegrationID,
		A.GroupID,
		A.SiteCode,
		A.ApprovalType,
		A.ApprovalSubType,
		A.ScreenParameter,
		A.IntegrationSequence,
		A.IntegrationType,
		A.Payload,
		A.Result,
		A.Error,
		A.[Status],
		A.RetryNumber,
		A.CreatedBy,
		A.UtcCreatedDate,
		A.LastModifiedBy,
		A.UtcLastModifiedDate
	FROM [dbo].[FLS_Integrations] A(NOLOCK)

