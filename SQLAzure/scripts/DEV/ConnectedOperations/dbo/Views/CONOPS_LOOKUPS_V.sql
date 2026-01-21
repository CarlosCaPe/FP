CREATE VIEW [dbo].[CONOPS_LOOKUPS_V] AS














/******************************************************************  
* VIEW	    : dbo.CONOPS_LOOKUPS_V
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 7 Jul 2023
* SAMPLE	: 
	1. SELECT * FROM dbo.CONOPS_LOOKUPS_V
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {7 Jul 2023}		{sxavier}		{Initial Created}
* {7 Jul 2023}		{ywibowo}		{Code Review}
*******************************************************************/ 


CREATE VIEW [dbo].[CONOPS_LOOKUPS_V]
AS
	SELECT
		A.TableType,
		A.TableCode,
		A.LanguageCode,
		A.[Value],
		A.[Description],
		A.IsActive,
		A.CreatedBy,
		A.UtcCreatedDate,
		A.ModifiedBy,
		A.UtcModifiedDate
	FROM [dbo].[LOOKUPS] A (NOLOCK)

