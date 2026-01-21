

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_MineProductivity_Get
* PURPOSE	: To get CDC of table mor.ShiftInfo
* NOTES		: Using by job_conops_shoft_info
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_MineProductivity_Get 'PREV', 'CVE'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}  
* {18 Nov 2022}		{sxavier}		{Add alias field name} 
* {18 Jan 2022}		{jrodulfa}		{Implement Safford data.} 
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {07 Feb 2023}		{jrodulfa}		{Implement Chino Data.}
* {10 Feb 2023}		{mbote}		    {Implement Cerro Verde Data.}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_MineProductivity_Get_OLD] 
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

	SELECT 
		ROUND(MineProductivity/1000,1) AS Actual, 
		ROUND([Target]/1000,1) AS ShiftTarget
	FROM [dbo].[CONOPS_LH_MINE_PRODUCTIVITY_V] (NOLOCK)
	WHERE 
		shiftflag = @SHIFT
		AND siteflag = @SITE;


SET NOCOUNT OFF
END

