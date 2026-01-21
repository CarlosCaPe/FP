
/******************************************************************  
* PROCEDURE	: dbo.EOS_ShovelInProduction_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 18 Jul 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_ShovelInProduction_Get 'CURR', 'BAG',1
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {18 Jul 2023}		{lwasini}		{Initial Created} 
* {01 Aug 2023}		{lwasini}		{Change to New View} 
* {06 Dec 2023}		{lwasini}		{Add Daily Summary} 
* {30 Jan 2024}		{lwasini}		{Add TYR & ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_ShovelInProduction_Get] 
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
			ISNULL(AVG(ShovelInProd),0) AS AVGShovelInProd
		FROM [bag].[CONOPS_BAG_EOS_SHOVELINPROD_V]
		WHERE shiftflag = @SHIFT;
		
		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			ShovelInProd,
			[DateTime]
		FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a
		LEFT JOIN [bag].[CONOPS_BAG_EOS_SHOVELINPROD_V] b
		ON a.shiftflag = b.shiftflag
		WHERE a.shiftflag = @SHIFT
		ORDER BY [DateTime] DESC;
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT
			ISNULL(AVG(ShovelInProd),0) AS AVGShovelInProd
		FROM [bag].[CONOPS_BAG_DAILY_EOS_SHOVELINPROD_V]
		WHERE shiftflag = @SHIFT;
		
		SELECT DISTINCT
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS ShiftStartDateTime,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime DESC) AS ShiftEndDateTime,
			ShovelInProd,
			[DateTime]
		FROM [bag].[CONOPS_BAG_EOS_SHIFT_INFO_V] a
		LEFT JOIN [bag].[CONOPS_BAG_DAILY_EOS_SHOVELINPROD_V] b
		ON a.shiftid = b.shiftid
		WHERE a.shiftflag = @SHIFT
		AND [DateTime] IS NOT NULL
		ORDER BY [DateTime] DESC;
		END
		
	END

	ELSE IF @SITE = 'CVE'
	BEGIN
		

		IF @DAILY = 0
		BEGIN
		SELECT
			ISNULL(AVG(ShovelInProd),0) AS AVGShovelInProd
		FROM [cer].[CONOPS_CER_EOS_SHOVELINPROD_V]
		WHERE shiftflag = @SHIFT;
		
		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			ShovelInProd,
			[DateTime]
		FROM [cer].[CONOPS_CER_SHIFT_INFO_V] a
		LEFT JOIN [cer].[CONOPS_CER_EOS_SHOVELINPROD_V] b
		ON a.shiftflag = b.shiftflag
		WHERE a.shiftflag = @SHIFT
		ORDER BY [DateTime] DESC;
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT
			ISNULL(AVG(ShovelInProd),0) AS AVGShovelInProd
		FROM [cer].[CONOPS_CER_DAILY_EOS_SHOVELINPROD_V]
		WHERE shiftflag = @SHIFT;
		
		SELECT DISTINCT
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS ShiftStartDateTime,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime DESC) AS ShiftEndDateTime,
			ShovelInProd,
			[DateTime]
		FROM [cer].[CONOPS_CER_EOS_SHIFT_INFO_V] a
		LEFT JOIN [cer].[CONOPS_CER_DAILY_EOS_SHOVELINPROD_V] b
		ON a.shiftid = b.shiftid
		WHERE a.shiftflag = @SHIFT
		AND [DateTime] IS NOT NULL
		ORDER BY [DateTime] DESC;
		END

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		
		IF @DAILY = 0
		BEGIN
		SELECT
			ISNULL(AVG(ShovelInProd),0) AS AVGShovelInProd
		FROM [chi].[CONOPS_CHI_EOS_SHOVELINPROD_V]
		WHERE shiftflag = @SHIFT;
		
		SELECT 
			ShiftStartDateTime,
			ShiftEndDateTime,
			ShovelInProd,
			[DateTime]
		FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] a
		LEFT JOIN [chi].[CONOPS_CHI_EOS_SHOVELINPROD_V] b
		ON a.shiftflag = b.shiftflag
		WHERE a.shiftflag = @SHIFT
		ORDER BY [DateTime] DESC;
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT
			ISNULL(AVG(ShovelInProd),0) AS AVGShovelInProd
		FROM [chi].[CONOPS_CHI_DAILY_EOS_SHOVELINPROD_V]
		WHERE shiftflag = @SHIFT;
		
		SELECT DISTINCT 
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS ShiftStartDateTime,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime DESC) AS ShiftEndDateTime,
			ShovelInProd,
			[Da