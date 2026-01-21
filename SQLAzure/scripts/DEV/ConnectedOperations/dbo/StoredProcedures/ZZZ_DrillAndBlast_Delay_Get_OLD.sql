

/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_Delay_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 14 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_Delay_Get 'PREV', 'SIE'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {14 Feb 2023}		{jrodulfa}		{Initial Created}  
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_Delay_Get_OLD] 
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
				END

	SELECT TOP 5
		reason AS ReasonName,
		CAST(reasonidx AS VARCHAR(10)) AS ReasonId,
		CAST(duration AS FLOAT) As TimeInHours
	FROM [dbo].[CONOPS_DB_DELAY_V] (NOLOCK)
	WHERE 
		shiftflag = @SHIFT
		AND siteflag = @SITE		
		
		ORDER BY duration DESC;


SET NOCOUNT OFF
END

