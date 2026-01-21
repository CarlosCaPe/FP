CREATE VIEW [mill].[KPIS_RANGE_V] AS

/******************************************************************  
* VIEW	    : mill.KPIS_V
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 21 Oct 2024
* SAMPLE	: 
	1. SELECT * FROM mill.KPIS_RANGE_V
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Oct 2024}		{sxavier}		{Initial Created}
*******************************************************************/ 


CREATE VIEW [mill].[KPIS_RANGE_V]
AS
	SELECT
		A.KpiRangeId,
		A.KpiId,
		A.MinValue,
		A.MaxValue,
		A.IsTarget,
		A.CreatedBy,
		A.UtcCreatedDate,
		A.ModifiedBy,
		A.UtcModifiedDate
	FROM mill.KpisRange A (NOLOCK)

