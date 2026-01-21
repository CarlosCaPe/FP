






/******************************************************************  
* PROCEDURE	: mill.Kpis_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier
* SAMPLE	: 
	1. EXEC mill.Kpis_Get 'CANYON', 'MOR', 'CON', 'MCF', 'EN'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {7 Oct 2024}		{sxavier}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [mill].[Kpis_Get]
(
	@KpiGroupId VARCHAR(8),
	@SiteCode VARCHAR(3),
	@ProcessId VARCHAR(3),
	@SubProcessId VARCHAR(3),
	@LanguageCode VARCHAR(5)
)
AS                        
BEGIN          
SET NOCOUNT ON
	
	SELECT
		A.KpiId,
		A.KpiUiType,
		A.KpiName,
		A.KpiSensorId,
		A.IsAllowNegativeValue,
		A.KpiUnit,
		B.MinValue,
		B.MaxValue,
		B.IsTarget
	FROM
		mill.KPIS_V A
		LEFT JOIN mill.KPIS_RANGE_V B ON A.KpiId = B.KpiId
	WHERE
		A.KpiGroupId = @KpiGroupId
		AND A.SiteCode = @SiteCode
		AND A.ProcessId = @ProcessId
		AND A.SubProcessId = @SubProcessId
		AND A.LanguageCode = @LanguageCode
	ORDER BY
		A.DisplayOrder

SET NOCOUNT OFF
END


