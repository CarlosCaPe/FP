


/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_AverageShiftChangeDelay_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 30 Nov 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_AverageShiftChangeDelay_Get 'PREV', 'SAF'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {30 Nov 2022}		{jrodulfa}		{Initial Created} 
* {02 Dec 2022}		{sxavier}		{Dispaly only needed data} 
* {11 Jan 2022}		{jrodulfa}		{Implement Bagdad data} 
* {18 Jan 2022}		{jrodulfa}		{Implement Safford data} 
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {03 Feb 2023}		{jrodulfa}		{Implement Chino Data.}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[zzz_LoadAndHaulOverview_AverageShiftChangeDelay_Get_OLD]
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

	SELECT COALESCE(Actual, 0) [Actual], [Target] AS ShiftTarget
	FROM [dbo].[CONOPS_LH_AVG_SHIFT_CHANGE_DELAY_V] WITH (NOLOCK)
	WHERE shiftflag = @SHIFT
		AND siteflag = @SITE

SET NOCOUNT OFF
END

