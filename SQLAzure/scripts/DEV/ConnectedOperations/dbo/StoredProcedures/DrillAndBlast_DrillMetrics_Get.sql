

/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrillMetrics_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 17 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrillMetrics_Get 'PREV', 'BAG'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Feb 2023}		{lwasini}		{Initial Created}  
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_DrillMetrics_Get] 
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

	---Feet Drilled
	SELECT
		DrillTime,
		FeetDrilled,
		FeetShiftTarget,
		FeetTarget
	FROM [dbo].[CONOPS_DB_FEETDRILL_SNAP_V] (NOLOCK)
	WHERE shiftflag = @SHIFT
		  AND siteflag = @SITE
	ORDER BY DrillTime DESC;


	---Holes Drilled
	SELECT
		DrillTime,
		HoleDrilled,
		HoleShiftTarget,
		HoleTarget
	FROM [dbo].[CONOPS_DB_HOLEDRILL_SNAP_V] (NOLOCK)
	WHERE shiftflag = @SHIFT
		  AND siteflag = @SITE
	ORDER BY DrillTime DESC;


SET NOCOUNT OFF
END

