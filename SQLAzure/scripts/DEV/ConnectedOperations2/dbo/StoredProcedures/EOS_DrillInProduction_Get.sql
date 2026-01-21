
/******************************************************************  
* PROCEDURE	: dbo.EOS_DrillInProduction_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 18 Jul 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_DrillInProduction_Get 'PREV', 'BAG',1
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {18 Jul 2023}		{lwasini}		{Initial Created} 
* {28 Jul 2023}		{lwasini}		{Add Drill for MOR} 
* {01 Aug 2023}		{lwasini}		{Change to New View} 
* {06 Dec 2023}		{lwasini}		{Add Daily Summary}
* {30 Jan 2024}		{lwasini}		{Add TYR & ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_DrillInProduction_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@DAILY INT
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN
		
		IF @DAILY = 0
		BEGIN
		SELECT
			ISNULL(AVG(DrillInProd),0) AS AVGDrillInProd
		FROM [bag].[CONOPS_BAG_EOS_DRILLINPROD_V]
		WHERE shiftflag = @SHIFT;
		
		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			DrillInProd,
			[DateTime]
		FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a
		LEFT JOIN [bag].[CONOPS_BAG_EOS_DRILLINPROD_V] b
		ON a.shiftflag = b.shiftflag
		WHERE a.shiftflag = @SHIFT
		ORDER BY [DateTime] DESC;
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT
			ISNULL(AVG(DrillInProd),0) AS AVGDrillInProd
		FROM [bag].[CONOPS_BAG_EOS_DRILLINPROD_V]
		WHERE shiftflag = @SHIFT;
		
		SELECT DISTINCT
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS ShiftStartDateTime,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime DESC) AS ShiftEndDateTime,
			DrillInProd,
			[DateTime]
		FROM [bag].[CONOPS_BAG_EOS_SHIFT_INFO_V] a
		LEFT JOIN [bag].[CONOPS_BAG_DAILY_EOS_DRILLINPROD_V] b
		ON a.shiftid = b.shiftid
		WHERE a.shiftflag = @SHIFT
		ORDER BY [DateTime] DESC;
		END
		
	END

	ELSE IF @SITE = 'CVE'
	BEGIN
		

		IF @DAILY = 0
		BEGIN
		SELECT
			ISNULL(AVG(DrillInProd),0) AS AVGDrillInProd
		FROM [cer].[CONOPS_CER_EOS_DRILLINPROD_V]
		WHERE shiftflag = @SHIFT;
		
		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			DrillInProd,
			[DateTime]
		FROM [cer].[CONOPS_CER_SHIFT_INFO_V] a
		LEFT JOIN [cer].[CONOPS_CER_EOS_DRILLINPROD_V] b
		ON a.shiftflag = b.shiftflag
		WHERE a.shiftflag = @SHIFT
		ORDER BY [DateTime] DESC;
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT
			ISNULL(AVG(DrillInProd),0) AS AVGDrillInProd
		FROM [cer].[CONOPS_CER_DAILY_EOS_DRILLINPROD_V]
		WHERE shiftflag = @SHIFT;
		
		SELECT DISTINCT 
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS ShiftStartDateTime,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime DESC) AS ShiftEndDateTime,
			DrillInProd,
			[DateTime]
		FROM [cer].[CONOPS_CER_EOS_SHIFT_INFO_V] a
		LEFT JOIN [cer].[CONOPS_CER_DAILY_EOS_DRILLINPROD_V] b
		ON a.shiftid = b.shiftid
		WHERE a.shiftflag = @SHIFT
		ORDER BY [DateTime] DESC;
		END

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		IF @DAILY = 0
		BEGIN
		SELECT
			ISNULL(AVG(DrillInProd),0) AS AVGDrillInProd
		FROM [chi].[CONOPS_CHI_EOS_DRILLINPROD_V]
		WHERE shiftflag = @SHIFT;
		
		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			DrillInProd,
			[DateTime]
		FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] a
		LEFT JOIN [chi].[CONOPS_CHI_EOS_DRILLINPROD_V] b
		ON a.shiftflag = b.shiftflag
		WHERE a.shiftflag = @SHIFT
		ORDER BY [DateTime] DESC;
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT
			ISNULL(AVG(DrillInProd),0) AS AVGDrillInProd
		FROM [chi].[CONOPS_CHI_DAILY_EOS_DRILLINPROD_V]
		WHERE shiftflag = @SHIFT;
		
		SELECT DISTINCT
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS ShiftStartDateTime,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime DESC) AS ShiftEndDateTime,
			DrillInProd,
			[DateTime]
		FROM [chi].[CONOPS_CHI_EOS_SHIFT_INFO_V] a