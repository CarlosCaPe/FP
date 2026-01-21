CREATE VIEW [mill].[KPIS_V] AS






















/******************************************************************  
* VIEW	    : mill.KPIS_V
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 7 Oct 2024
* SAMPLE	: 
	1. SELECT * FROM mill.KPIS_V
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {7 Oct 2024}		{sxavier}		{Initial Created}
* {21 Oct 2024}		{sxavier}		{Add KpiUiType}
*******************************************************************/ 


CREATE VIEW [mill].[KPIS_V]
AS
	SELECT
		A.KpiId,
		A.SiteCode,
		A.ProcessId,
		A.SubProcessId,
		A.KpiGroupId,
		C.[Value] AS KpiUiType,
		B.KpiName,
		A.KpiSensorId,
		A.IsAllowNegativeValue,
		B.KpiUnit,
		B.LanguageCode,
		A.DisplayOrder,
		A.CreatedBy,
		A.UtcCreatedDate,
		A.ModifiedBy,
		A.UtcModifiedDate
	FROM mill.Kpis A (NOLOCK)
	JOIN mill.KpisName B (NOLOCK) ON A.KpiId = B.KpiId
	LEFT JOIN dbo.LOOKUPS C (NOLOCK) ON C.TableType = 'KPUI' AND A.KpiUiType = C.TableCode

