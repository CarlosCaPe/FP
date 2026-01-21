
/******************************************************************  
* PROCEDURE	: dbo.Operator_ShovelDetail_Get 
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 06 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.Operator_ShovelDetail_Get 'PREV', 'TYR', '0000061092'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {06 Apr 2023}		{ggosal1}		{Initial Created} 
* {22 Jan 2024}		{lwasini}		{Add TYR}
* {24 Jan 2024}		{lwasini}		{Add ABR}  
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Operator_ShovelDetail_Get] 
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
			[d].ShiftFlag
			,[d].SiteFlag
			,[d].[ShovelID]
			,[Operator]
			,[d].[OperatorId]
			,[OperatorImageURL]
			,[CrewName]
			,[Location]
			,[ol].[STARTDATETIME] AS ShiftStartDateTime
			,[ol].[ENDDATETIME] AS ShiftEndDateTime
			,[ot].JOB_TITLE AS Title
			, NULL AS ShiftCheckList
			,'30' AS EvaluationDays
			,ISNULL([cw].NROFDAYS, 0) AS ConsecutiveWorkDays
		FROM [BAG].[CONOPS_BAG_OPERATOR_SHOVEL_V] [d]
		LEFT JOIN BAG.CONOPS_BAG_OPERATOR_SHOVEL_LOGIN_V [ol]
			ON [d].shiftflag = ol.[SHIFTFLAG]
			AND [d].[OPERATORID] = [ol].[OPERATORID]
		LEFT JOIN [BAG].[CONOPS_BAG_SHOVEL_OPERATOR_CONSECUTIVE_WORKDAYS_V] [cw]
			ON [d].SHIFTINDEX = [cw].shiftindex
			AND [d].OperatorId = [cw].OPERID
		LEFT JOIN [dbo].[OPERATOR_TITLE] [ot] WITH(NOLOCK)
			ON [d].OperatorId = [ot].OPERATOR_ID
		WHERE [d].ShiftFlag = @SHIFT
			AND [d].OperatorId = @OPERID;

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
			[d].ShiftFlag
			,[d].SiteFlag
			,[d].[ShovelID]
			,[Operator]
			,[d].[OperatorId]
			,[OperatorImageURL]
			,[CrewName]
			,[Location]
			,[ol].[STARTDATETIME] AS ShiftStartDateTime
			,[ol].[ENDDATETIME] AS ShiftEndDateTime
			,[ot].JOB_TITLE AS Title
			, NULL AS ShiftCheckList
			,'30' AS EvaluationDays
			,ISNULL([cw].NROFDAYS, 0) AS ConsecutiveWorkDays
		FROM [CER].[CONOPS_CER_OPERATOR_SHOVEL_V] [d]
		LEFT JOIN CER.CONOPS_CER_OPERATOR_SHOVEL_LOGIN_V [ol]
			ON [d].shiftflag = ol.[SHIFTFLAG]
			AND [d].[OPERATORID] = [ol].[OPERATORID]
		LEFT JOIN [CER].[CONOPS_CER_SHOVEL_OPERATOR_CONSECUTIVE_WORKDAYS_V] [cw]
			ON [d].SHIFTINDEX = [cw].shiftindex
			AND [d].OperatorId = [cw].OPERID
		LEFT JOIN [dbo].[OPERATOR_TITLE] [ot] WITH(NOLOCK)
			ON [d].OperatorId = [ot].OPERATOR_ID
		WHERE [d].ShiftFlag = @SHIFT
			AND [d].OperatorId = @OPERID;

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT 
			[d].ShiftFlag
			,[d].SiteFlag
			,[d].[ShovelID]
			,[Operator]
			,[d].[OperatorId]
			,[OperatorImageURL]
			,[CrewName]
			,[Location]
			,[ol].[STARTDATETIME] AS ShiftStartDateTime
			,[ol].[ENDDATETIME] AS ShiftEndDateTime
			,[ot].JOB_TITLE AS Title
			, NULL AS ShiftCheckList
			,'30' AS EvaluationDays
			,ISNULL([cw].NROFDAYS, 0) AS ConsecutiveWorkDays
		FROM [CHI].[CONOPS_CHI_OPERATOR_SHOVEL_V] [d]
		LEFT JOIN CHI.CONOPS_CHI_OPERATOR_SHOVEL_LOGIN_V [ol]
			ON [d].shiftflag = ol.[SHIFTFLAG]
			AND [d].[OPERATORID] = [ol].[OPERATORID]
		LEFT JOIN [CHI].[CONOPS_CHI_SHOVEL_OPERATOR_CONSECUTIVE_WORKDAYS_V] [cw]
			ON [d].SHIFTINDEX = [cw].shiftindex
			AND [d].OperatorId = [cw].OPERID
		LEFT JOIN [dbo].[OPERATOR_TITLE] [ot] WITH(NOLOCK)
			ON [d].OperatorId = [ot].OPERATOR_ID
		WHERE [d].ShiftFlag = @SHIFT
			AND [d].OperatorId = @OPERID;

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT 
			[d].ShiftFlag
			,[d].SiteFlag
			,[d].[ShovelID]
			,[Operator]
			,[d].[OperatorId]
			,[OperatorImageURL]
			,[CrewName]
			,[Location]
			,[ol].[STARTDATETIME] AS ShiftStartDateTime
			,[ol].[ENDDATETIME] AS ShiftEndDateTime
			,[ot].JOB_TITLE AS Title
			, NULL AS ShiftCheckList
			,'30' AS EvaluationDays
			,ISNULL([cw].NROFDAYS, 0) AS ConsecutiveWorkDays
		FROM [C