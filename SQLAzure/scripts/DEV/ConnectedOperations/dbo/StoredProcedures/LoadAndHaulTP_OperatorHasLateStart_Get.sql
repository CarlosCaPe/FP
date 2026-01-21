

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_OperatorHasLateStart_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 28 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_OperatorHasLateStart_Get 'PREV', 'MOR', NULL, NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {30 Dec 2022}		{jrodulfa}		{Initial Created}
* {30 Dec 2022}		{sxavier}		{Rename field}
* {25 May 2023}		{jrodulfa}		{Updated the logic for First Load Data}
* {01 Sep 2023}		{lwasini}		{Add Parameter Equipment Type}
* {10 Nov 2023}     {lwasini}		{Add 15 Minutes to ShiftStartDatetime}
* {28 Nov 2023}     {lwasini}		{Add OperatorId}
* {03 Jan 2024}     {lwasini}		{Added TYR}
* {23 Jan 2024}     {lwasini}		{Add ABR}
* {09 May 2025}		{ggosal1}		{Add Autonomous Filter}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_OperatorHasLateStart_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX),
	@EQMTTYPE NVARCHAR(MAX),
	@AUTONOMOUS INT
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT
			eqmtid AS [Name],
			UPPER(OperatorName) [OperatorName],
			[ls].OperatorImageURL AS ImageURL,
			[ls].OperatorId,
			FirstLoginTime AS [Time],
			t.Region,
			--DATEDIFF(Minute, ShiftStartDateTime, [FirstLoginDateTime]) [LateStartMinute],
			DATEDIFF(Minute, DATEADD(MINUTE,15,SHIFTSTARTDATETIME), [FirstLoginDateTime]) [LateStartMinute],
			[FirstLoginDateTime] [LateStartDateTime],
			DATEDIFF(Minute, ShiftStartDateTime, [FirstLoadDateTime]) AS FirstLoadLateTime,
			[FirstLoadTS] AS FirstLoadLateTimeStamp,
			[FirstLoadDateTime] [FirstLoadLateDate]
		FROM BAG.[CONOPS_BAG_OPERATOR_HAS_LATE_START_V] [ls] WITH (NOLOCK)
		LEFT JOIN BAG.[CONOPS_BAG_TRUCK_DETAIL_V] [t]
			ON [ls].shiftflag = [t].shiftflag AND [ls].siteflag = [t].siteflag
			AND eqmtid = [t].TruckID
		LEFT JOIN BAG.[CONOPS_BAG_SHOVEL_INFO_V] [s] WITH (NOLOCK)
			ON [t].shiftflag = [s].shiftflag
			AND [t].AssignedShovel = [s].ShovelID
		WHERE [ls].shiftflag = @SHIFT
			AND unit_code = 1
			AND ([t].TruckID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '') 
			AND ([t].eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '') 
			AND (UPPER([t].StatusName) IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
			AND ([t].TruckID IN (SELECT TruckID FROM BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V WHERE Autonomous = @AUTONOMOUS) OR ISNULL(@AUTONOMOUS, '') = '')
		ORDER BY FirstLoginTime desc

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			eqmtid AS [Name],
			UPPER(OperatorName) [OperatorName],
			[ls].OperatorImageURL AS ImageURL,
			[ls].OperatorId,
			FirstLoginTime AS [Time],
			t.Region,
			--DATEDIFF(Minute, ShiftStartDateTime, [FirstLoginDateTime]) [LateStartMinute],
			DATEDIFF(Minute, DATEADD(MINUTE,15,SHIFTSTARTDATETIME), [FirstLoginDateTime]) [LateStartMinute],
			[FirstLoginDateTime] [LateStartDateTime],
			DATEDIFF(Minute, ShiftStartDateTime, [FirstLoadDateTime]) AS FirstLoadLateTime,
			[FirstLoadTS] AS FirstLoadLateTimeStamp,
			[FirstLoadDateTime] [FirstLoadLateDate]
		FROM CER.[CONOPS_CER_OPERATOR_HAS_LATE_START_V] [ls] WITH (NOLOCK)
		LEFT JOIN CER.[CONOPS_CER_TRUCK_DETAIL_V] [t]
			ON [ls].shiftflag = [t].shiftflag AND [ls].siteflag = [t].siteflag
			AND eqmtid = [t].TruckID
		LEFT JOIN CER.[CONOPS_CER_SHOVEL_INFO_V] [s] WITH (NOLOCK)
			ON [t].shiftflag = [s].shiftflag
			AND [t].AssignedShovel = [s].ShovelID
		WHERE [ls].shiftflag = @SHIFT
			AND unit_code = 1
			AND ([t].TruckID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '') 
			AND ([t].eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@