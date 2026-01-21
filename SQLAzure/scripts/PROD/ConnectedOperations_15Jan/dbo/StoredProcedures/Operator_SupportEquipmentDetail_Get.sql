

/******************************************************************  
* PROCEDURE	: dbo.Operator_SupportEquipmentDetail_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 02 May 2023
* SAMPLE	: 
	1. EXEC dbo.Operator_SupportEquipmentDetail_Get 'CURR', 'TYR', '0000061092'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {02 May 2023}		{ggosal1}		{Initial Created}  
* {22 Jan 2024}		{lwasini}		{Add TYR}
* {24 Jan 2024}		{lwasini}		{Add ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Operator_SupportEquipmentDetail_Get] 
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
			[d].OperatorId,
			Operator,
			OperatorImageURL,
			CrewName,
			[Location],
			[d].SupportEquipmentId,
			[StatusName] AS [Status],
			[ol].[STARTDATETIME] AS ShiftStartDateTime,
			[ol].[ENDDATETIME] AS ShiftEndDateTime,
			[ot].JOB_TITLE AS Title,
			NULL AS ShiftChecklist,
			'30' AS EvaluationDays,
			ISNULL([cw].NROFDAYS, 0) AS ConsecutiveWorkDays
		FROM [BAG].[CONOPS_BAG_OPERATOR_SUPPORT_EQMT_V] [d]
		LEFT JOIN BAG.CONOPS_BAG_OPERATOR_SUPPORT_EQMT_LOGIN_V [ol]
			ON [d].shiftindex = ol.shiftindex
			AND [d].[OPERATORID] = [ol].[OPERATORID]
		LEFT JOIN [BAG].[CONOPS_BAG_SUPPORT_EQMT_OPERATOR_CONSECUTIVE_WORKDAYS_V] [cw]
			ON [d].shiftindex = [cw].shiftindex
			AND [d].[OPERATORID] = [cw].OPERID
		LEFT JOIN [dbo].[OPERATOR_TITLE] [ot]
			ON [d].OperatorId = [ot].OPERATOR_ID
		WHERE [d].SHIFTFLAG = @SHIFT
			AND [d].OperatorId = @OPERID

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			[d].OperatorId,
			Operator,
			OperatorImageURL,
			CrewName,
			[Location],
			[d].SupportEquipmentId,
			[StatusName] AS [Status],
			[ol].[STARTDATETIME] AS ShiftStartDateTime,
			[ol].[ENDDATETIME] AS ShiftEndDateTime,
			[ot].JOB_TITLE AS Title,
			NULL AS ShiftChecklist,
			'30' AS EvaluationDays,
			ISNULL([cw].NROFDAYS, 0) AS ConsecutiveWorkDays
		FROM [CER].[CONOPS_CER_OPERATOR_SUPPORT_EQMT_V] [d]
		LEFT JOIN CER.CONOPS_CER_OPERATOR_SUPPORT_EQMT_LOGIN_V [ol]
			ON [d].shiftindex = ol.shiftindex
			AND [d].[OPERATORID] = [ol].[OPERATORID]
		LEFT JOIN [CER].[CONOPS_CER_SUPPORT_EQMT_OPERATOR_CONSECUTIVE_WORKDAYS_V] [cw]
			ON [d].shiftindex = [cw].shiftindex
			AND [d].[OPERATORID] = [cw].OPERID
		LEFT JOIN [dbo].[OPERATOR_TITLE] [ot]
			ON [d].OperatorId = [ot].OPERATOR_ID
		WHERE [d].SHIFTFLAG = @SHIFT
			AND [d].OperatorId = @OPERID

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT
			[d].OperatorId,
			Operator,
			OperatorImageURL,
			CrewName,
			[Location],
			[d].SupportEquipmentId,
			[StatusName] AS [Status],
			[ol].[STARTDATETIME] AS ShiftStartDateTime,
			[ol].[ENDDATETIME] AS ShiftEndDateTime,
			[ot].JOB_TITLE AS Title,
			NULL AS ShiftChecklist,
			'30' AS EvaluationDays,
			ISNULL([cw].NROFDAYS, 0) AS ConsecutiveWorkDays
		FROM [CHI].[CONOPS_CHI_OPERATOR_SUPPORT_EQMT_V] [d]
		LEFT JOIN CHI.CONOPS_CHI_OPERATOR_SUPPORT_EQMT_LOGIN_V [ol]
			ON [d].shiftindex = ol.shiftindex
			AND [d].[OPERATORID] = [ol].[OPERATORID]
		LEFT JOIN [CHI].[CONOPS_CHI_SUPPORT_EQMT_OPERATOR_CONSECUTIVE_WORKDAYS_V] [cw]
			ON [d].shiftindex = [cw].shiftindex
			AND [d].[OPERATORID] = [cw].OPERID
		LEFT JOIN [dbo].[OPERATOR_TITLE] [ot]
			ON [d].OperatorId = [ot].OPERATOR_ID
		WHERE [d].SHIFTFLAG = @SHIFT
			AND [d].OperatorId = @OPERID

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT
			[d].OperatorId,
			Operator,
			OperatorImageURL,
			CrewName,
			[Location],
			[d].SupportEquipmentId,
			[StatusName] AS [Status],
			[ol].[STARTDATETIME] AS ShiftStartDateTime,
			[ol].[ENDDATETIME] AS ShiftEndDateTime,
			[ot].JOB_TITLE AS Title,
			NULL AS ShiftChecklist,
			'30' AS EvaluationDays,
			ISNULL([cw].NROFDAYS, 0) AS ConsecutiveWorkDay