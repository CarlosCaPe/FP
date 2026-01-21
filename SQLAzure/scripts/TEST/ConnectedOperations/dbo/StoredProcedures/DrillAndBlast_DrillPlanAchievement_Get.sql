
/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrillPlanAchievement_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 08 Dec 2025
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrillPlanAchievement_Get 'MOR'	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {08 Dec 2025}		{ggosal1}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_DrillPlanAchievement_Get] 
(	
	@SITE VARCHAR(4)
)
AS                        
BEGIN   

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN
	
		SELECT NULL
	
	END
	
	ELSE IF @SITE = 'CVE'
	BEGIN
	
		SELECT NULL
	
	END
	
	ELSE IF @SITE = 'CHN'
	BEGIN
	
		SELECT NULL
	
	END
	
	ELSE IF @SITE = 'CMX'
	BEGIN
	
		SELECT NULL
	
	END
	
	ELSE IF @SITE = 'MOR'
	BEGIN
	
		SELECT TOP 10
			WEEK_START_DATE,
			BLAST_DATE_COMPLIANCE_PCT,
			PATTERN_COMPLIANCE_PCT
		FROM MOR.CONOPS_MOR_DB_PLAN_ACHIEVEMENT_V
		WHERE WEEK_START_DATE IS NOT NULL
		ORDER BY WEEK_START_DATE DESC;
	
	END
	
	ELSE IF @SITE = 'SAM'
	BEGIN
	
		SELECT NULL
	
	END
	
	ELSE IF @SITE = 'SIE'
	BEGIN
	
		SELECT NULL
	
	END

	ELSE IF @SITE = 'TYR'
	BEGIN
	
		SELECT NULL
	
	END

	ELSE IF @SITE = 'ABR'
	BEGIN
	
		SELECT NULL
	
	END

SET NOCOUNT OFF

END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH

END








