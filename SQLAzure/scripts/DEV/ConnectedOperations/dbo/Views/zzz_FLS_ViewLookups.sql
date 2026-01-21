CREATE VIEW [dbo].[zzz_FLS_ViewLookups] AS






/******************************************************************  
* VIEW	    : dbo.FLS_ViewLookups
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 17 Apr 2023
* SAMPLE	: 
	1. SELECT * FROM dbo.FLS_ViewLookups
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Apr 2023}		{sxavier}		{Initial Created}
* {24 Apr 2023}		{ywibowo}		{Code review.}
*******************************************************************/ 


CREATE VIEW [dbo].[FLS_ViewLookups]
AS
	SELECT
		A.TableType,
		A.TableCode,
		A.TableExtension,
		A.[Value],
		A.[Description],
		A.CreatedBy,
		A.UtcCreatedDate,
		A.LastModifiedBy,
		A.UtcLastModifiedDate
	FROM [dbo].[FLS_Lookups] A(NOLOCK)

