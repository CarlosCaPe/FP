CREATE VIEW [mill].[KPIS_GROUP_V] AS


/******************************************************************  
* VIEW	    : mill.CARD_KPIS_V
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 7 Oct 2024
* SAMPLE	: 
	1. SELECT * FROM mill.KPIS_GROUP_V
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {7 Oct 2024}		{sxavier}		{Initial Created}
*******************************************************************/ 


CREATE VIEW [mill].[KPIS_GROUP_V]
AS
	SELECT
		A.SiteCode,
		A.ProcessId,
		A.SubProcessId,
		A.KpiGroupId,
		A.KpiGroupName,
		A.CreatedBy,
		A.UtcCreatedDate,
		A.ModifiedBy,
		A.UtcModifiedDate
	FROM mill.KpisGroup A (NOLOCK)

