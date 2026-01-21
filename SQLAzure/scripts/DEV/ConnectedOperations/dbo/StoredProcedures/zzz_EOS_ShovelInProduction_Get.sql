








/******************************************************************  
* PROCEDURE	: dbo.EOS_ShovelInProduction_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 18 Jul 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_ShovelInProduction_Get 'PREV', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {18 Jul 2023}		{lwasini}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[zzz_EOS_ShovelInProduction_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	IF @SITE = 'BAG'
	BEGIN
		
		SELECT
			ISNULL(AVG(Equipment),0) AS AVGShovelInProd
		FROM [bag].[CONOPS_BAG_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Shovel';
		
		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			Equipment AS ShovelInProd,
			[DateTime]
		FROM [bag].[CONOPS_BAG_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Shovel'
		ORDER BY [DateTime] DESC;
		
	END

	ELSE IF @SITE = 'CVE'
	BEGIN
		
		SELECT 
			ISNULL(AVG(Equipment),0) AS AVGShovelInProd
		FROM [cer].[CONOPS_CER_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Pala';
		
		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			Equipment AS ShovelInProd,
			[DateTime]
		FROM [cer].[CONOPS_CER_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Pala'
		ORDER BY [DateTime] DESC;

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		
		SELECT
			ISNULL(AVG(Equipment),0) AS AVGShovelInProd
		FROM [chi].[CONOPS_CHI_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Shovel';
		
		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			Equipment AS ShovelInProd,
			[DateTime]
		FROM [chi].[CONOPS_CHI_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Shovel'
		ORDER BY [DateTime] DESC;

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT 
			ISNULL(AVG(Equipment),0) AS AVGShovelInProd
		FROM [cli].[CONOPS_CLI_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Shovel';
		
		
		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			Equipment AS ShovelInProd,
			[DateTime]
		FROM [cli].[CONOPS_CLI_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Shovel'
		ORDER BY [DateTime] DESC;

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT 
			ISNULL(AVG(Equipment),0) AS AVGShovelInProd
		FROM [mor].[CONOPS_MOR_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Shovel';
		
		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			Equipment AS ShovelInProd,
			[DateTime]
		FROM [mor].[CONOPS_MOR_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Shovel'
		ORDER BY [DateTime] DESC;


	END

	ELSE IF @SITE = 'SAM'
	BEGIN

		SELECT 
			ISNULL(AVG(Equipment),0) AS AVGShovelInProd
		FROM [saf].[CONOPS_SAF_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Shovel';
		
		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			Equipment AS ShovelInProd,
			[DateTime]
		FROM [saf].[CONOPS_SAF_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Shovel'
		ORDER BY [DateTime] DESC;

	END

	ELSE IF @SITE = 'SIE'
	BEGIN

		SELECT 
			ISNULL(AVG(Equipment),0) AS AVGShovelInProd
		FROM [sie].[CONOPS_SIE_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Shovel';
		
		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			Equipment AS ShovelInProd,
			[DateTime]
		FROM [sie].[CONOPS_SIE_EOS_TRUCK_READY_V]
		WHERE shiftflag = @SHIFT
		AND UnitType = 'Shovel'
		ORDER BY [DateTime] DESC;

	END

END


