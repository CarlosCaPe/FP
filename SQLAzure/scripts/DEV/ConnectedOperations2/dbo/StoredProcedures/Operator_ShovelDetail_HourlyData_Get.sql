
/******************************************************************  
* PROCEDURE	: dbo.Operator_ShovelDetail_HourlyData_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 19 May 2023
* SAMPLE	: 
	1. EXEC dbo.Operator_ShovelDetail_HourlyData_Get 'PREV', 'BAG', '0060067308'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {19 May 2023}		{ggosal1}		{Initial Created}  
* {30 Aug 2023}		{lwasini}		{Add Hangtime}  
* {22 Jan 2024}		{lwasini}		{Add TYR}  
* {24 Jan 2024}		{lwasini}		{Add ABR}  
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Operator_ShovelDetail_HourlyData_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@OPERID VARCHAR(50)
)
AS                        
BEGIN  

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT
			shiftflag,
			OperatorId,
			ROUND(payload,0) Payload,
			PayloadTarget,
			TotalMaterialMoved/1000.00 AS TonsMoved,
			TotalMaterialMovedTarget/1000.00  AS TonsMovedTarget,
			ROUND(Spotting,2) Spotting,
			SpottingTarget,
			TotalMaterialMined/1000.00 AS TotalMaterialMined,
			TotalMaterialMinedTarget/1000.00 AS TotalMaterialMinedTarget,
			ROUND(UseOfAvailability,2) UseOfAvailability,
			ROUND(useOfAvailabilityTarget,2) useOfAvailabilityTarget,
			ROUND(Loading,2) Loading,
			LoadingTarget,
			ROUND(IdleTime,2) IdleTime,
			IdleTimeTarget,
			ROUND(Hangtime,2) Hangtime,
			HangtimeTarget,
			ToothMetrics,
			ToothMetricsTarget
		FROM BAG.[CONOPS_BAG_OPERATOR_SHOVEL_V]
		WHERE shiftflag = @SHIFT
			AND OPERATORID = @OPERID;

		SELECT
			[tprh].shiftflag,
			[op].OperatorId,
			[tprh].Hr,
			ROUND(ISNULL([tprh].TPRH, 0), 2) AS TPRH
		FROM [BAG].[CONOPS_BAG_EQMT_SHOVEL_HOURLY_TPRH_V] [tprh]
		LEFT OUTER JOIN BAG.[CONOPS_BAG_OPERATOR_SHOVEL_LIST_V] [op]
			ON [tprh].shiftflag = [op].shiftflag AND [tprh].EQMT = [op].ShovelID
		WHERE [tprh].shiftflag = @SHIFT
			AND [op].OPERATORID = @OPERID
		ORDER BY Hr

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			shiftflag,
			OperatorId,
			ROUND(payload,0) Payload,
			PayloadTarget,
			TotalMaterialMoved/1000.00 AS TonsMoved,
			TotalMaterialMovedTarget/1000.00  AS TonsMovedTarget,
			ROUND(Spotting,2) Spotting,
			SpottingTarget,
			TotalMaterialMined/1000.00 AS TotalMaterialMined,
			TotalMaterialMinedTarget/1000.00 AS TotalMaterialMinedTarget,
			ROUND(UseOfAvailability,2) UseOfAvailability,
			ROUND(useOfAvailabilityTarget,2) useOfAvailabilityTarget,
			ROUND(Loading,2) Loading,
			LoadingTarget,
			ROUND(IdleTime,2) IdleTime,
			IdleTimeTarget,
			ROUND(Hangtime,2) Hangtime,
			HangtimeTarget,
			ToothMetrics,
			ToothMetricsTarget
		FROM CER.[CONOPS_CER_OPERATOR_SHOVEL_V]
		WHERE shiftflag = @SHIFT
			AND OPERATORID = @OPERID;

		SELECT
			[tprh].shiftflag,
			[op].OperatorId,
			[tprh].Hr,
			ROUND(ISNULL([tprh].TPRH, 0), 2) AS TPRH
		FROM [CER].[CONOPS_CER_EQMT_SHOVEL_HOURLY_TPRH_V] [tprh]
		LEFT OUTER JOIN CER.[CONOPS_CER_OPERATOR_SHOVEL_LIST_V] [op]
			ON [tprh].shiftflag = [op].shiftflag AND [tprh].EQMT = [op].ShovelID
		WHERE [tprh].shiftflag = @SHIFT
			AND [op].OPERATORID = @OPERID
		ORDER BY Hr

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT
			shiftflag,
			OperatorId,
			ROUND(payload,0) Payload,
			PayloadTarget,
			TotalMaterialMoved/1000.00 AS TonsMoved,
			TotalMaterialMovedTarget/1000.00  AS TonsMovedTarget,
			ROUND(Spotting,2) Spotting,
			SpottingTarget,
			TotalMaterialMined/1000.00 AS TotalMaterialMined,
			TotalMaterialMinedTarget/1000.00 AS TotalMaterialMinedTarget,
			ROUND(UseOfAvailability,2) UseOfAvailability,
			ROUND(useOfAvailabilityTarget,2) useOfAvailabilityTarget,
			ROUND(Loading,2) Loading,
			LoadingTarget,
			ROUND(IdleTime,2) IdleTime,
			IdleTimeTarget,
			ROUND(Hangtime,2) Hangtime,
			HangtimeTarget,
			ToothMetrics,
			ToothMetricsTarget
		FROM CHI.[CONOPS_CHI_OPERATOR_SHOVEL_V]