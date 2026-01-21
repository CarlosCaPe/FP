CREATE VIEW [dbo].[CONOPS_LOGBOOK_LOOKUPS_V] AS


/******************************************************************  
* VIEW	    : dbo.CONOPS_LOGBOOK_LOOKUPS_V
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 29 Sep 2023
* SAMPLE	: 
	1. SELECT * FROM dbo.CONOPS_LOGBOOK_LOOKUPS_V
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {29 Sep 2023}		{sxavier}		{Initial Created}
* {29 Sep 2023}		{ywibowo}		{Code Review}
* {23 Oct 2023}		{sxavier}		{Add SiteCode, ProcessId, adn SubProcessId}
*******************************************************************/ 


CREATE VIEW [dbo].[CONOPS_LOGBOOK_LOOKUPS_V]
AS
	SELECT
		A.LogbookType,
		A.SiteCode,
		A.ProcessId,
		A.SubProcessId,
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
	FROM [dbo].[LOGBOOK_LOOKUPS] A (NOLOCK)

