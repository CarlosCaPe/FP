







/******************************************************************  
* PROCEDURE	: mill.Settings_HighLowLimit_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier
* SAMPLE	: 
	1. EXEC mill.Settings_HighLowLimit_Get 'MOR', 'CON', 'MCF', 'EN'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {7 Oct 2024}		{sxavier}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [mill].[Settings_HighLowLimit_Get]
(
	@SiteCode VARCHAR(3),
	@ProcessId VARCHAR(3),
	@SubProcessId VARCHAR(3),
	@LanguageCode VARCHAR(5)
)
AS                        
BEGIN          
SET NOCOUNT ON
	
	SELECT
		A.KpiGroupId,
		A.KpiId,
		A.KpiName,
		A.KpiUnit,
		B.MinValue,
		B.MaxValue
	FROM
		mill.KPIS_V A
		LEFT JOIN mill.KPIS_RANGE_V B ON A.KpiId = B.KpiId
	WHERE
		A.SiteCode = @SiteCode
		AND A.ProcessId = @ProcessId
		AND A.SubProcessId = @SubProcessId
		AND A.LanguageCode = @LanguageCode
		AND (B.IsTarget = 1 OR B.IsTarget IS NULL)
	ORDER BY
		A.KpiGroupId,
		A.DisplayOrder

SET NOCOUNT OFF
END


