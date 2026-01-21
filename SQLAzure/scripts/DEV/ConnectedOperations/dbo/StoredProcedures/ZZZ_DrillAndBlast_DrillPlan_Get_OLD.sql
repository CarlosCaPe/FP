



/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrillPlan_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 17 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrillPlan_Get 'PREV', 'BAG',NULL,NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Feb 2023}		{lwasini}		{Initial Created} 
* {21 Feb 2023}		{sxavier}		{Rename field.} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_DrillPlan_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX)
)
AS                        
BEGIN          
	
	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;

	---Holes Drilled & Feet Drilled
	SELECT
		sum(HolesDrilled) AS HolesDrilled,
		HoleShiftTarget AS HolesDrilledShiftTarget,
		HoleTarget AS HolesDrilledTarget,
		sum(FeetDrilled) AS FeetDrilled,
		FeetShiftTarget AS FeetDrilledShiftTarget,
		FeetTarget AS FeetDrilledTarget
	FROM [dbo].[CONOPS_DB_DRILL_PLAN_V] (NOLOCK)
	WHERE shiftflag = @SHIFT
		  AND siteflag = @SITE
		   AND (Equipment IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		  AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
	GROUP BY HoleShiftTarget,HoleTarget,FeetShiftTarget,FeetTarget;


SET NOCOUNT OFF
END

