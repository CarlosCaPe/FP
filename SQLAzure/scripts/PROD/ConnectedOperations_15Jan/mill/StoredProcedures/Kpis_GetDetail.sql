
/******************************************************************  
* PROCEDURE	: mill.Kpis_GetDetail
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier
* SAMPLE	: 
	1. EXEC mill.Kpis_GetDetail 'B12RCRT1', 'MOR', 'CON', 'MCF', 'EN'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2024}		{sxavier}		{Initial Created}
* {26 Nov 2024}		{sxavier}		{Return IsAllowNegativeValue}
*******************************************************************/ 
CREATE PROCEDURE [mill].[Kpis_GetDetail]
(
	@KpiId VARCHAR(8),
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
		A.KpiSensorId,
		A.IsAllowNegativeValue,
		B.MinValue,
		B.MaxValue
	FROM
		mill.KPIS_V A
		LEFT JOIN mill.KPIS_RANGE_V B ON A.KpiId = B.KpiId
	WHERE
		A.KpiId = @KpiId
		AND A.SiteCode = @SiteCode
		AND A.ProcessId = @ProcessId
		AND A.SubProcessId = @SubProcessId
		AND A.LanguageCode = @LanguageCode
		AND (B.IsTarget IS NULL OR B.IsTarget = 1)
	ORDER BY
		A.DisplayOrder

SET NOCOUNT OFF
END

