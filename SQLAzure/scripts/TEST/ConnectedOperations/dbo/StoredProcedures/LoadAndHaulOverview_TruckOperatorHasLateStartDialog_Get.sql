





/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_TruckOperatorHasLateStartDialog_Get
* PURPOSE	: Get data for Truck Operator Has Late Start Dialog
* NOTES		: 
* CREATED	: sxavier, 13 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_TruckOperatorHasLateStartDialog_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {13 Dec 2022}		{sxavier}		{Initial Created} 
* {03 Jan 2023}		{jrodulfa}		{Implemented Dialog Detail for Operator Late Start} 
* {25 May 2023}		{jrodulfa}		{Updated the logic for First Load Data}
* {28 Nov 2023}		{lwasini}		{Add OperatorId}
* {03 Jan 2024}		{lwasini}		{Added TYR}
* {23 Jan 2024}		{lwasini}		{Add ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TruckOperatorHasLateStartDialog_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          

	IF @SITE = 'BAG'
	BEGIN

		SELECT eqmtid AS [Name],
			UPPER(OperatorName) [OperatorName],
			[t].OperatorImageURL AS ImageURL,
			[t].OperatorId,
			FirstLoginTime AS [Time],
			s.Region,
			DATEDIFF(Minute, ShiftStartDateTime, [FirstLoginDateTime]) [LateStartMinute],
			[FirstLoginDateTime] [LateStartDateTime],
			DATEDIFF(Minute, ShiftStartDateTime, [FirstLoadDateTime]) AS FirstLoadLateTime,
			[FirstLoadTS] AS FirstLoadLateTimeStamp,
			[FirstLoadDateTime] [FirstLoadLateDate]
		FROM BAG.[CONOPS_BAG_OPERATOR_HAS_LATE_START_V] [ls] WITH (NOLOCK)
		LEFT JOIN BAG.[CONOPS_BAG_TRUCK_DETAIL_V] [t]
			ON [ls].shiftflag = [t].shiftflag
			AND eqmtid = [t].TruckID
		LEFT JOIN BAG.[CONOPS_BAG_SHOVEL_INFO_V] [s] WITH (NOLOCK)
			ON [t].shiftflag = [s].shiftflag
			AND [t].AssignedShovel = [s].ShovelID
		WHERE [ls].shiftflag = @SHIFT
			AND unit_code = 1
		ORDER BY FirstLoginTime desc

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT eqmtid AS [Name],
			UPPER(OperatorName) [OperatorName],
			[t].OperatorImageURL AS ImageURL,
			[t].OperatorId,
			FirstLoginTime AS [Time],
			s.Region,
			DATEDIFF(Minute, ShiftStartDateTime, [FirstLoginDateTime]) [LateStartMinute],
			[FirstLoginDateTime] [LateStartDateTime],
			DATEDIFF(Minute, ShiftStartDateTime, [FirstLoadDateTime]) AS FirstLoadLateTime,
			[FirstLoadTS] AS FirstLoadLateTimeStamp,
			[FirstLoadDateTime] [FirstLoadLateDate]
		FROM CER.[CONOPS_CER_OPERATOR_HAS_LATE_START_V] [ls] WITH (NOLOCK)
		LEFT JOIN CER.[CONOPS_CER_TRUCK_DETAIL_V] [t]
			ON [ls].shiftflag = [t].shiftflag
			AND eqmtid = [t].TruckID
		LEFT JOIN CER.[CONOPS_CER_SHOVEL_INFO_V] [s] WITH (NOLOCK)
			ON [t].shiftflag = [s].shiftflag
			AND [t].AssignedShovel = [s].ShovelID
		WHERE [ls].shiftflag = @SHIFT
			AND unit_code = 1
		ORDER BY FirstLoginTime desc

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT eqmtid AS [Name],
			UPPER(OperatorName) [OperatorName],
			[t].OperatorImageURL AS ImageURL,
			[t].OperatorId,
			FirstLoginTime AS [Time],
			s.Region,
			DATEDIFF(Minute, ShiftStartDateTime, [FirstLoginDateTime]) [LateStartMinute],
			[FirstLoginDateTime] [LateStartDateTime],
			DATEDIFF(Minute, ShiftStartDateTime, [FirstLoadDateTime]) AS FirstLoadLateTime,
			[FirstLoadTS] AS FirstLoadLateTimeStamp,
			[FirstLoadDateTime] [FirstLoadLateDate]
		FROM CHI.[CONOPS_CHI_OPERATOR_HAS_LATE_START_V] [ls] WITH (NOLOCK)
		LEFT JOIN CHI.[CONOPS_CHI_TRUCK_DETAIL_V] [t]
			ON [ls].shiftflag = [t].shiftflag
			AND eqmtid = [t].TruckID
		LEFT JOIN CHI.[CONOPS_CHI_SHOVEL_INFO_V] [s] WITH (NOLOCK)
			ON [t].shiftflag = [s].shiftflag
			AND [t].AssignedShovel = [s].ShovelID
		WHERE [ls].shiftflag = @SHIFT
			AND unit_code = 1
		ORDER BY FirstLoginTime desc

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT eqmtid AS [Name],
			UPPER(OperatorName) [OperatorName],
			[t].OperatorImageURL AS ImageURL,
			[t].OperatorId,
