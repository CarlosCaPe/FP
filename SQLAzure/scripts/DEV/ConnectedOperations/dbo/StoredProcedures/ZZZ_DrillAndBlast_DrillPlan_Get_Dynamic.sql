



/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrillPlan_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 17 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrillPlan_Get 'PREV', 'SIE',NULL,NULL
	
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
	
	DECLARE @SCHEMA VARCHAR(4);

	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;

	SET @SCHEMA = CASE @SITE 
					   WHEN 'CMX' THEN 'CLI'
					   ELSE @SITE
				  END;

	EXEC('SELECT ISNULL(SUM(HolesDrilled), 0) AS HolesDrilled,
			     ISNULL(AVG([HolesDrilledShiftTarget]), 0) AS HolesDrilledShiftTarget,
				 ISNULL(AVG([HolesDrilledTarget]), 0) AS HolesDrilledTarget,
				 ISNULL(SUM(FeetDrilled), 0) AS FeetDrilled,
				 ISNULL(AVG([FeetDrilledShiftTarget]), 0) AS FeetDrilledShiftTarget,
				 ISNULL(AVG([FeetDrilledTarget]), 0) AS FeetDrilledTarget
		 FROM [' + @SCHEMA + '].[CONOPS_' + @SCHEMA + '_DB_DRILL_PLAN_V] (NOLOCK)
		 WHERE shiftflag = ''' + @SHIFT + '''
		 	   AND siteflag = ''' + @SITE + '''
			   AND (DRILL_ID IN (SELECT TRIM(value) FROM STRING_SPLIT(''' + @EQMT + ''', '','')) OR ISNULL(''' + @EQMT + ''', '''') = '''')
			   AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(''' + @STATUS + '''), '','')) OR ISNULL(''' + @STATUS + ''', '''') = '''')');

SET NOCOUNT OFF
END

