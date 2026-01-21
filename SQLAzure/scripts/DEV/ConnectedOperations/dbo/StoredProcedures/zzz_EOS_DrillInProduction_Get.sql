

/******************************************************************  
* PROCEDURE	: dbo.EOS_DrillInProduction_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 18 Jul 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_DrillInProduction_Get 'PREV', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {18 Jul 2023}		{lwasini}		{Initial Created} 
* {28 Jul 2023}		{lwasini}		{Add Drill for MOR} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[zzz_EOS_DrillInProduction_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	IF @SITE = 'BAG'
	BEGIN
		
		SELECT
			ISNULL(AVG(Equipment),0) AS AVGDrillInProd
		FROM [bag].[CONOPS_BAG_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Drill';
		
		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			Equipment AS DrillInProd,
			[DateTime]
		FROM [bag].[CONOPS_BAG_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Drill'
		ORDER BY [DateTime] DESC;
		
	END

	ELSE IF @SITE = 'CVE'
	BEGIN
		
		SELECT 
			ISNULL(AVG(Equipment),0) AS AVGDrillInProd
		FROM [cer].[CONOPS_CER_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Drill';


		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			Equipment AS DrillInProd,
			[DateTime]
		FROM [cer].[CONOPS_CER_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Drill'
		ORDER BY [DateTime] DESC;

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		
		SELECT
			ISNULL(AVG(Equipment),0) AS AVGDrillInProd
		FROM [chi].[CONOPS_CHI_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Drill';
		
		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			Equipment AS DrillInProd,
			[DateTime]
		FROM [chi].[CONOPS_CHI_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Drill'
		ORDER BY [DateTime] DESC;

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT 
			ISNULL(AVG(Equipment),0) AS AVGDrillInProd
		FROM [cli].[CONOPS_CLI_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Drill';
		
		
		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			Equipment AS DrillInProd,
			[DateTime]
		FROM [cli].[CONOPS_CLI_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Drill'
		ORDER BY [DateTime] DESC;

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT 
			ISNULL(AVG(Equipment),0) AS AVGDrillInProd
		FROM [mor].[CONOPS_MOR_EOS_DRILL_READY_V]
		WHERE shiftflag = @SHIFT;
		
		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			Equipment AS DrillInProd,
			[DateTime]
		FROM [mor].[CONOPS_MOR_EOS_DRILL_READY_V]
		WHERE shiftflag = @SHIFT
		ORDER BY [DateTime] DESC;


	END

	ELSE IF @SITE = 'SAM'
	BEGIN

		SELECT 
			ISNULL(AVG(Equipment),0) AS AVGDrillInProd
		FROM [saf].[CONOPS_SAF_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Drill';
		
		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			Equipment AS DrillInProd,
			[DateTime]
		FROM [saf].[CONOPS_SAF_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Drill'
		ORDER BY [DateTime] DESC;

	END

	ELSE IF @SITE = 'SIE'
	BEGIN

		SELECT 
			ISNULL(AVG(Equipment),0) AS AVGDrillInProd
		FROM [sie].[CONOPS_SIE_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Drill';
		
		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			Equipment AS DrillInProd,
			[DateTime]
		FROM [sie].[CONOPS_SIE_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Drill'
		ORDER BY [DateTime] DESC;

	END

END


