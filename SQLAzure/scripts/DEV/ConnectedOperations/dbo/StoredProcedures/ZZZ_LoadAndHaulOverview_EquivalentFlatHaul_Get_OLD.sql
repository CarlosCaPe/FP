

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_EquivalentFlatHaul_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_EquivalentFlatHaul_Get 'CURR', 'CVE'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created} 
* {21 Nov 2022}		{sxavier}		{Refactor query}  
* {25 Jan 2023}		{jrodulfa}		{Implement Safford Data}  
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {03 Feb 2023}		{jrodulfa}		{Implement Chino Data.}
* {10 Feb 2023}		{mbote}	   	    {Implement Cerro Verde Data.}
* {14 Feb 2023}		{sxavier}	   	{Remove field Target.}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_EquivalentFlatHaul_Get_OLD] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;

	SELECT *
	INTO 
		#TempTable
	FROM 
		[dbo].[CONOPS_LH_EFH_V] (NOLOCK)
	WHERE shiftflag = @SHIFT
		AND siteflag = @SITE

	SELECT TOP(1) 
		EFHShiftTarget AS ShiftTarget,
		ShiftStartDateTime AS StartDate,
		ShiftEndDateTime AS EndDate,
		avgEFH AS OverallEfh
		--20.5 AS OverallEfh --Remove harcoded when value ready
	FROM 
		#TempTable
	
	ORDER BY breakbyhour DESC;

	SELECT 
		EFH AS [Value], 
		breakbyhour AS [DateTime]
	FROM 
		#TempTable
	ORDER BY breakbyhour DESC;
	
	DROP TABLE #TempTable

SET NOCOUNT OFF
END

