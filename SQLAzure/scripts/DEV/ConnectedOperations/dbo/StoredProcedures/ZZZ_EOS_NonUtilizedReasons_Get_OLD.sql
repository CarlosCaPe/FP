

/******************************************************************  
* PROCEDURE	: dbo.EOS_NonUtilizedReasons_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 17 May 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_NonUtilizedReasons_Get 'PREV', 'BAG'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 May 2023}		{jrodulfa}		{Initial Created} 
* {22 Jun 2023}		{jrodulfa}		{Added Drill NonUtilized Reason} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_NonUtilizedReasons_Get_OLD] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	IF @SITE = 'BAG'
	BEGIN

		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) As TimeInHours
		FROM [bag].[CONOPS_BAG_EOS_TRUCK_NON_UTILIZED_REASON_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) As TimeInHours
		FROM [bag].[CONOPS_BAG_EOS_SHOVEL_NON_UTILIZED_REASON_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) As TimeInHours
		FROM [bag].[CONOPS_BAG_EOS_DRILL_NON_UTILIZED_REASON_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) As TimeInHours
		FROM [bag].[CONOPS_BAG_EOS_CRUSHER_NON_UTILIZED_REASON_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) As TimeInHours
		FROM [cer].[CONOPS_CER_EOS_TRUCK_NON_UTILIZED_REASON_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) As TimeInHours
		FROM [CER].[CONOPS_CER_EOS_SHOVEL_NON_UTILIZED_REASON_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) As TimeInHours
		FROM [cer].[CONOPS_CER_EOS_DRILL_NON_UTILIZED_REASON_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) As TimeInHours
		FROM [CER].[CONOPS_CER_EOS_CRUSHER_NON_UTILIZED_REASON_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) As TimeInHours
		FROM [CHI].[CONOPS_CHI_EOS_TRUCK_NON_UTILIZED_REASON_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) As TimeInHours
		FROM [CHI].[CONOPS_CHI_EOS_SHOVEL_NON_UTILIZED_REASON_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) As TimeInHours
		FROM [chi].[CONOPS_CHI_EOS_DRILL_NON_UTILIZED_REASON_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) As TimeInHours
		FROM [CHI].[CONOPS_CHI_EOS_CRUSHER_NON_UTILIZED_REASON_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) As TimeInHours
		FROM [CLI].[CONOPS_CLI_EOS_TRUCK_NON_UTILIZED_REASON_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY DurationHours DESC;

		SELECT TOP 5
			UnitType,
			reason AS ReasonName,
			CAST(DurationHours AS FLOAT) 