

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulSP_OperatorHasLateStart_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 03 Jan 2023
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulSP_OperatorHasLateStart_Get 'PREV', 'BAG', NULL, NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {03 Jan 2023}		{jrodulfa}		{Initial Created}
* {25 May 2023}		{jrodulfa}		{Updated the logic for First Load Data}
* {31 Aug 2023}		{jrodulfa}		{Add Parameter Equipment Type}
* {10 Nov 2023}     {lwasini}		{Add 15 Minutes to ShiftStartDatetime}
* {28 Nov 2023}     {lwasini}		{Add OperatorId}
* {03 Jan 2024}     {lwasini}		{Added TYR}
* {23 Jan 2024}		{lwasini}		{Add ABR}
* {11 Nov 2025}		{dbonardo}		{Split string using udt}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulSP_OperatorHasLateStart_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX),
	@EQMTTYPE NVARCHAR(MAX)
)
AS                        
BEGIN          

	DECLARE @splitEqmt [dbo].[udTT_SplitValue];
	DECLARE @splitEStat [dbo].[udTT_SplitValue];
	DECLARE @splitEType [dbo].[udTT_SplitValue];

	INSERT INTO @splitEqmt ([Value]) SELECT TRIM([value]) FROM STRING_SPLIT(@EQMT, ',');
	INSERT INTO @splitEStat ([Value]) SELECT TRIM([value]) FROM STRING_SPLIT(@STATUS, ',');
	INSERT INTO @splitEType ([Value]) SELECT TRIM([value]) FROM STRING_SPLIT(@EQMTTYPE, ',');

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT
			eqmtid AS [Name],
			UPPER(OperatorName) [OperatorName],
			[ls].OperatorImageURL AS ImageURL,
			RIGHT('0000000000' + [ls].[OperatorId], 10) OperatorId,
			FirstLoginTime AS [Time],
			s.Region,
			--DATEDIFF(Minute, ShiftStartDateTime, [FirstLoginDateTime]) [LateStartMinute],
			DATEDIFF(Minute, DATEADD(MINUTE,15,SHIFTSTARTDATETIME), [FirstLoginDateTime]) [LateStartMinute],
			[FirstLoginDateTime] [LateStartDateTime],
			DATEDIFF(Minute, ShiftStartDateTime, [FirstLoadDateTime]) AS FirstLoadLateTime,
			[FirstLoadTS] AS FirstLoadLateTimeStamp,
			[FirstLoadDateTime] [FirstLoadLateDate]
		FROM BAG.[CONOPS_BAG_OPERATOR_HAS_LATE_START_V] [ls] WITH (NOLOCK)
		LEFT JOIN BAG.[CONOPS_BAG_SHOVEL_INFO_V] [s] WITH (NOLOCK)
			ON [ls].shiftflag = [s].shiftflag AND [ls].siteflag = [s].siteflag
			AND eqmtid = [s].ShovelID
		WHERE [ls].shiftflag = @SHIFT
			AND unit_code = 2
			AND ([s].ShovelID IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND ([s].eqmttype IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND ([s].StatusName IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
		ORDER BY FirstLoginTime DESC

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			eqmtid AS [Name],
			UPPER(OperatorName) [OperatorName],
			[ls].OperatorImageURL AS ImageURL,
			RIGHT('0000000000' + [ls].[OperatorId], 10) OperatorId,
			FirstLoginTime AS [Time],
			s.Region,
			--DATEDIFF(Minute, ShiftStartDateTime, [FirstLoginDateTime]) [LateStartMinute],
			DATEDIFF(Minute, DATEADD(MINUTE,15,SHIFTSTARTDATETIME), [FirstLoginDateTime]) [LateStartMinute],
			[FirstLoginDateTime] [LateStartDateTime],
			DATEDIFF(Minute, ShiftStartDateTime, [FirstLoadDateTime]) AS FirstLoadLateTime,
			[FirstLoadTS] AS FirstLoadLateTimeStamp,
			[FirstLoadDateTime] [FirstLoadLateDate]
		FROM CER.[CONOPS_CER_OPERATOR_HAS_LATE_START_V] [ls] WITH (NOLOCK)
		LEFT JOIN CER.[CONOPS_CER_SHOVEL_INFO_V] [s] WITH (NOLOCK)
			ON [ls].shiftflag = [s].shiftflag AND [ls].siteflag = [s].siteflag
			AND eqmtid = [s].ShovelID
		WHERE [ls].shiftflag = @SHIFT
			AND unit_code = 2
			AND ([s].ShovelID IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND ([s].eqmttype IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND ([s].StatusName IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
		ORDER BY FirstLoginTime