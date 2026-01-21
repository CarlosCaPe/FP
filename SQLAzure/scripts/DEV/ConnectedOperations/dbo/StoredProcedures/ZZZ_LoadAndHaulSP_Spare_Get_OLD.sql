


/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulSP_Spare_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulSP_Spare_Get 'PREV', 'CVE'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created} 
* {6 Dec 2022}		{sxavier}		{Rename field}
* {24 Jan 2023}		{jrodulfa}		{Implement Safford Data.}
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {01 Feb 2023}		{jrodulfa}		{Implement Chino Data.}
* {02 Feb 2023}		{mbote}		    {Implement Cerro Verde Data.}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulSP_Spare_Get_OLD] 
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
	
	SELECT TOP 5
		reasons AS ReasonName,
		CAST(reasonidx AS VARCHAR(10)) AS ReasonId,
		CAST(duration AS FLOAT) As TimeInHours
	FROM [dbo].[CONOPS_LH_SP_SPARE_V] (NOLOCK)
	WHERE 
		shiftflag = @SHIFT
		AND siteflag = @SITE
		ORDER BY duration DESC;


SET NOCOUNT OFF
END

