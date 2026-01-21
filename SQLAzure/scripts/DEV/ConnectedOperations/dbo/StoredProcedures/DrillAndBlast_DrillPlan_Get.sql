










/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrillPlan_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 17 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrillPlan_Get 'PREV', 'SAM', NULL, NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Feb 2023}		{lwasini}		{Initial Created} 
* {21 Feb 2023}		{sxavier}		{Rename field.}
* {04 Sep 2023}		{ggosal1}		{Add Parameter Equipment Type} 
* {03 Jan 2024}		{lwasini}		{Added TYR} 
* {09 Jan 2024}		{lwasini}		{Added ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_DrillPlan_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX),
	@EQMTTYPE NVARCHAR(MAX)
)
AS                        
BEGIN          
	
	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN
		 SELECT  ISNULL(SUM(HolesDrilled), 0) AS HolesDrilled,
			     ISNULL(AVG([HolesDrilledShiftTarget]), 0) AS HolesDrilledShiftTarget,
				 ISNULL(AVG([HolesDrilledTarget]), 0) AS HolesDrilledTarget,
				 ISNULL(SUM(FeetDrilled), 0) AS FeetDrilled,
				 ISNULL(AVG([FeetDrilledShiftTarget]), 0) AS FeetDrilledShiftTarget,
				 ISNULL(AVG([FeetDrilledTarget]), 0) AS FeetDrilledTarget
		 FROM [bag].[CONOPS_BAG_DB_DRILL_PLAN_V] (NOLOCK)
		 WHERE shiftflag = @SHIFT
		 	   AND siteflag = @SITE
			   AND (DRILL_ID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			   AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS ), ',')) OR ISNULL(@STATUS, '') = '')
			   AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
	END

	ELSE IF @SITE = 'CER'
	BEGIN
		 SELECT  ISNULL(SUM(HolesDrilled), 0) AS HolesDrilled,
			     ISNULL(AVG([HolesDrilledShiftTarget]), 0) AS HolesDrilledShiftTarget,
				 ISNULL(AVG([HolesDrilledTarget]), 0) AS HolesDrilledTarget,
				 ISNULL(SUM(FeetDrilled), 0) AS FeetDrilled,
				 ISNULL(AVG([FeetDrilledShiftTarget]), 0) AS FeetDrilledShiftTarget,
				 ISNULL(AVG([FeetDrilledTarget]), 0) AS FeetDrilledTarget
		 FROM [cer].[CONOPS_CER_DB_DRILL_PLAN_V] (NOLOCK)
		 WHERE shiftflag = @SHIFT
		 	   AND siteflag = @SITE
			   AND (DRILL_ID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			   AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS ), ',')) OR ISNULL(@STATUS, '') = '')
			   AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
	END

	ELSE IF @SITE = 'CHI'
	BEGIN
		 SELECT  ISNULL(SUM(HolesDrilled), 0) AS HolesDrilled,
			     ISNULL(AVG([HolesDrilledShiftTarget]), 0) AS HolesDrilledShiftTarget,
				 ISNULL(AVG([HolesDrilledTarget]), 0) AS HolesDrilledTarget,
				 ISNULL(SUM(FeetDrilled), 0) AS FeetDrilled,
				 ISNULL(AVG([FeetDrilledShiftTarget]), 0) AS FeetDrilledShiftTarget,
				 ISNULL(AVG([FeetDrilledTarget]), 0) AS FeetDrilledTarget
		 FROM [chi].[CONOPS_CHI_DB_DRILL_PLAN_V] (NOLOCK)
		 WHERE shiftflag = @SHIFT
		 	   AND siteflag = @SITE
			   AND (DRILL_ID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			   AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS ), ',')) OR ISNULL(@STATUS, '') = '')
			   AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
	END

	ELSE IF @SITE = 'CMX'
	BEGIN
		 SELECT  ISNULL(SUM(HolesDrilled), 0) AS HolesDrilled,
			     ISNULL(AVG([HolesDrilledShiftTarget]), 0) AS HolesDrilledShiftTarget,
				 ISNULL(AVG([HolesDrilledTarget]), 0) AS HolesDrilledTarget,
				 ISNULL(SUM(FeetDrilled), 0) AS FeetDrilled,
				 ISNULL