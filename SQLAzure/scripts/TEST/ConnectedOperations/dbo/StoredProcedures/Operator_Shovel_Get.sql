





/******************************************************************  
* PROCEDURE	: dbo.Operator_Shovel_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 06 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.Operator_Shovel_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Mar 2023}		{ggosal1}		{Initial Created}  
* {30 Aug 2023}		{lwasini}		{Add Hangtime}
* {27 Oct 2023}		{ggosal1}		{MVP 8.2 Add Tons Moved, remove delta c & no of loads} 
* {22 Jan 2024}		{lwasini}		{Add TYR}  
* {24 Jan 2024}		{lwasini}		{Add ABR}  
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Operator_Shovel_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN  

	IF @SITE = 'BAG'
	BEGIN

		SELECT 
			ShovelId,
			OperatorId,
			UPPER ([Operator]) AS OperatorName,
			OperatorImageURL,
			OperatorStatus,
			[StatusName] AS [Status],
			ROUND(TonsPerReadyHour,2) AS TonsPerReadyHour,
			TonsPerReadyHourTarget,
			ROUND(Payload,0) AS Payload,
			PayloadTarget,
			ROUND(TotalMaterialMined,2) AS TotalMaterialMined,
			ROUND(TotalMaterialMinedTarget,2) AS TotalMaterialMinedTarget,
			ROUND(TotalMaterialMoved,2) AS TotalMaterialMoved,
			ROUND(TotalMaterialMovedTarget,2) AS TotalMaterialMovedTarget,
			ToothMetrics,
			ToothMetricsTarget,
			ROUND(UseOfAvailability,2) AS UseOfAvailability,
			UseOfAvailabilityTarget,
			ROUND(Loading,2) AS Loading,
			LoadingTarget,
			ROUND(Spotting,2) AS Spotting,
			SpottingTarget,
			ROUND(IdleTime,2) AS IdleTime,
			IdleTimeTarget,
			ROUND(Hangtime,2) AS Hangtime,
			HangtimeTarget
		FROM [BAG].[CONOPS_BAG_OPERATOR_SHOVEL_V]
		WHERE SHIFTFLAG = @SHIFT

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
			ShovelId,
			OperatorId,
			UPPER ([Operator]) AS OperatorName,
			OperatorImageURL,
			OperatorStatus,
			[StatusName] AS [Status],
			ROUND(TonsPerReadyHour,2) AS TonsPerReadyHour,
			TonsPerReadyHourTarget,
			ROUND(Payload,0) AS Payload,
			PayloadTarget,
			ROUND(TotalMaterialMined,2) AS TotalMaterialMined,
			ROUND(TotalMaterialMinedTarget,2) AS TotalMaterialMinedTarget,
			ROUND(TotalMaterialMoved,2) AS TotalMaterialMoved,
			ROUND(TotalMaterialMovedTarget,2) AS TotalMaterialMovedTarget,
			ToothMetrics,
			ToothMetricsTarget,
			ROUND(UseOfAvailability,2) AS UseOfAvailability,
			UseOfAvailabilityTarget,
			ROUND(Loading,2) AS Loading,
			LoadingTarget,
			ROUND(Spotting,2) AS Spotting,
			SpottingTarget,
			ROUND(IdleTime,2) AS IdleTime,
			IdleTimeTarget,
			ROUND(Hangtime,2) AS Hangtime,
			HangtimeTarget
		FROM [CER].[CONOPS_CER_OPERATOR_SHOVEL_V]
		WHERE SHIFTFLAG = @SHIFT

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT 
			ShovelId,
			OperatorId,
			UPPER ([Operator]) AS OperatorName,
			OperatorImageURL,
			OperatorStatus,
			[StatusName] AS [Status],
			ROUND(TonsPerReadyHour,2) AS TonsPerReadyHour,
			TonsPerReadyHourTarget,
			ROUND(Payload,0) AS Payload,
			PayloadTarget,
			ROUND(TotalMaterialMined,2) AS TotalMaterialMined,
			ROUND(TotalMaterialMinedTarget,2) AS TotalMaterialMinedTarget,
			ROUND(TotalMaterialMoved,2) AS TotalMaterialMoved,
			ROUND(TotalMaterialMovedTarget,2) AS TotalMaterialMovedTarget,
			ToothMetrics,
			ToothMetricsTarget,
			ROUND(UseOfAvailability,2) AS UseOfAvailability,
			UseOfAvailabilityTarget,
			ROUND(Loading,2) AS Loading,
			LoadingTarget,
			ROUND(Spotting,2) AS Spotting,
			SpottingTarget,
			ROUND(IdleTime,2) AS IdleTime,
			IdleTimeTarget,
			ROUND(Hangtime,2) AS Hangtime,
			HangtimeTarget
		FROM [CHI].[CONOPS_CHI_OPERATOR_SHOVEL_V]
		WHERE SHIFTFLAG = @SHIFT

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT 
			ShovelId,
			OperatorId,
			UPPER ([Operator]) AS OperatorName,
			OperatorImageURL,
			OperatorStatus,
			[StatusName] AS [Status],
			ROUND(TonsPerReadyHour,2) AS TonsP