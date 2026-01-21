





/******************************************************************  
* PROCEDURE	: dbo.EOS_LunchBreak_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 20 Jul 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_LunchBreak_Get 'CURR', 'CVE',1
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {20 Jul 2023}		{lwasini}		{Initial Created} 
* {04 Dec 2023}		{lwasini}		{Add Daily Summary}
* {30 Jan 2024}		{lwasini}		{Add TYR & ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_LunchBreak_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@DAILY INT
)
AS                        
BEGIN          
	
	IF @SITE = 'BAG'
	BEGIN
		
		IF @DAILY = 0 
		BEGIN
		SELECT 
			CAST(SUM(Duration)/60.0 AS INT) LunchBreakDuration
		FROM [bag].[CONOPS_BAG_EOS_EQMT_BREAK_V]
		WHERE shiftflag = @SHIFT
		AND Reason = 400
		AND UnitType = 'Truck';
		END

		ELSE IF @DAILY = 1 
		BEGIN
		SELECT 
			CAST(SUM(Duration)/60.0 AS INT) LunchBreakDuration
		FROM [bag].[CONOPS_BAG_DAILY_EOS_EQMT_BREAK_V]
		WHERE shiftflag = @SHIFT
		AND Reason = 400
		AND UnitType = 'Truck';
		END
		
		
	END

	ELSE IF @SITE = 'CVE'
	BEGIN
		

		IF @DAILY = 0
		BEGIN
		SELECT 
			CAST(SUM(Duration)/60.0 AS INT) LunchBreakDuration
		FROM [cer].[CONOPS_CER_EOS_EQMT_BREAK_V]
		WHERE shiftflag = @SHIFT
		AND Reason IN (401,321)
		AND UnitType = 'Camion';
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT 
			CAST(SUM(Duration)/60.0 AS INT) LunchBreakDuration
		FROM [cer].[CONOPS_CER_DAILY_EOS_EQMT_BREAK_V]
		WHERE shiftflag = @SHIFT
		AND Reason IN (401,321)
		AND UnitType = 'Camion';
		END

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		
		IF @DAILY = 0
		BEGIN
		SELECT 
			CAST(SUM(Duration)/60.0 AS INT) LunchBreakDuration
		FROM [chi].[CONOPS_CHI_EOS_EQMT_BREAK_V]
		WHERE shiftflag = @SHIFT
		AND Reason = 400
		AND UnitType = 'Truck';
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT 
			CAST(SUM(Duration)/60.0 AS INT) LunchBreakDuration
		FROM [chi].[CONOPS_CHI_DAILY_EOS_EQMT_BREAK_V]
		WHERE shiftflag = @SHIFT
		AND Reason = 400
		AND UnitType = 'Truck';
		END

	END

	ELSE IF @SITE = 'CMX'
	BEGIN


		IF @DAILY = 0
		BEGIN
		SELECT 
			CAST(SUM(Duration)/60.0 AS INT) LunchBreakDuration
		FROM [cli].[CONOPS_CLI_EOS_EQMT_BREAK_V]
		WHERE shiftflag = @SHIFT
		AND Reason = 400
		AND UnitType = 'Truck';
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT 
			CAST(SUM(Duration)/60.0 AS INT) LunchBreakDuration
		FROM [cli].[CONOPS_CLI_DAILY_EOS_EQMT_BREAK_V]
		WHERE shiftflag = @SHIFT
		AND Reason = 400
		AND UnitType = 'Truck';
		END

		
	END

	ELSE IF @SITE = 'MOR'
	BEGIN


		IF @DAILY = 0
		BEGIN
		SELECT 
			CAST(SUM(Duration)/60.0 AS INT) LunchBreakDuration
		FROM [mor].[CONOPS_MOR_EOS_EQMT_BREAK_V]
		WHERE shiftflag = @SHIFT
		AND Reason = 400
		AND UnitType = 'Truck';
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT 
			CAST(SUM(Duration)/60.0 AS INT) LunchBreakDuration
		FROM [mor].[CONOPS_MOR_DAILY_EOS_EQMT_BREAK_V]
		WHERE shiftflag = @SHIFT
		AND Reason = 400
		AND UnitType = 'Truck';
		END

		
	END

	ELSE IF @SITE = 'SAM'
	BEGIN


		IF @DAILY = 0
		BEGIN
		SELECT 
			CAST(SUM(Duration)/60.0 AS INT) LunchBreakDuration
		FROM [saf].[CONOPS_SAF_EOS_EQMT_BREAK_V]
		WHERE shiftflag = @SHIFT
		AND Reason = 400
		AND UnitType = 'Truck';
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT 
			CAST(SUM(Duration)/60.0 AS INT) LunchBreakDuration
		FROM [saf].[CONOPS_SAF_DAILY_EOS_EQMT_BREAK_V]
		WHERE shiftflag = @SHIFT
		AND Reason = 400
		AND UnitType = 'Truck';
		END

		

	END

	ELSE IF @SITE = 'SIE'
	BEGIN


		IF @DAILY = 0
		BEGIN
		SELECT 
			CAST(SUM(Duration)/60.0 AS INT) LunchBreakDuration
		FROM [sie].[CONOPS_SIE_EOS_EQMT_BREAK_V]
		WHERE shiftflag = @SHIFT
		AND Reason = 400
		AND UnitType = 'Truck';
		END

		ELSE 