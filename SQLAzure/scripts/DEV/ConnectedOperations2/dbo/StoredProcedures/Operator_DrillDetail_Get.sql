
/******************************************************************  
* PROCEDURE	: dbo.Operator_DrillDetail_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 19 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.Operator_DrillDetail_Get 'CURR', 'BAG', '0000061307'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {19 Apr 2023}		{jrodulfa}		{Initial Created}  
* {22 Jan 2024}		{lwasini}		{Add TYR}
* {22 Apr 2024}		{ggosal1}		{Add ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Operator_DrillDetail_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@OPERID VARCHAR(50)
)
AS                        
BEGIN  

	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN
		SELECT TOP 1 [d].[shiftflag]
			  ,[d].[siteflag]
			  ,[d].[OPERATORID]
			  ,[OperatorName]
			  ,[OperatorImageURL] as ImageUrl
			  ,[d].[DRILL_ID]
			  ,[CREW]
			  ,[PATTERN_NO] AS [Location]
			  ,[ol].[STARTDATETIME] AS ShiftStart
			  ,[ol].[ENDDATETIME] AS ShiftEnd
			  ,[ot].JOB_TITLE AS Title
			  , NULL AS ShiftCheckList
			  , 30 AS Evaluation
			  ,ISNULL([cw].NROFDAYS, 0) AS ConsecutiveWorkDays
		FROM [bag].[CONOPS_BAG_DRILL_DETAIL_V] [d]
		LEFT JOIN bag.CONOPS_BAG_OPERATOR_DRILL_LOGIN_V [ol]
		ON [d].shiftflag = ol.[SHIFTFLAG]
		   AND [d].[OPERATORID] = [ol].[OPERATORID] AND [d].DRILL_ID = [ol].DRILL_ID
		LEFT JOIN [bag].[CONOPS_BAG_DRILL_OPERATOR_CONSECUTIVE_WORKDAYS_V] [cw]
		ON [d].ShiftIndex = [cw].Shiftindex
		   AND [d].OPERATORID = [cw].OPERID
		LEFT JOIN [dbo].[OPERATOR_TITLE] [ot] WITH(NOLOCK)
		ON [d].OperatorId = [ot].OPERATOR_ID
		WHERE [d].shiftflag = @SHIFT
			  AND [d].siteflag =  @SITE
			  AND [d].OPERATORID = @OPERID;
	END

	ELSE IF @SITE = 'CER'
	BEGIN
		SELECT TOP 1 [d].[shiftflag]
			  ,[d].[siteflag]
			  ,[d].[OPERATORID]
			  ,[OperatorName]
			  ,[OperatorImageURL] as ImageUrl
			  ,[d].[DRILL_ID]
			  ,[CREW]
			  ,[PATTERN_NO] AS [Location]
			  ,[ol].[STARTDATETIME] AS ShiftStart
			  ,[ol].[ENDDATETIME] AS ShiftEnd
			  ,[ot].JOB_TITLE AS Title
			  , NULL AS ShiftCheckList
			  , 30 AS Evaluation
			  , ISNULL([cw].NROFDAYS, 0) AS ConsecutiveWorkDays
		FROM [CER].[CONOPS_CER_DRILL_DETAIL_V] [d]
		LEFT JOIN cer.CONOPS_CER_OPERATOR_DRILL_LOGIN_V [ol]
		ON [d].shiftflag = ol.[SHIFTFLAG]
		   AND [d].[OPERATORID] = [ol].[OPERATORID] AND [d].DRILL_ID = [ol].DRILL_ID
		LEFT JOIN [cer].[CONOPS_CER_DRILL_OPERATOR_CONSECUTIVE_WORKDAYS_V] [cw]
		ON [d].ShiftIndex = [cw].Shiftindex
		   AND [d].OPERATORID = [cw].OPERID
		LEFT JOIN [dbo].[OPERATOR_TITLE] [ot] WITH(NOLOCK)
		ON [d].OperatorId = [ot].OPERATOR_ID
		WHERE [d].shiftflag = @SHIFT
			  AND [d].siteflag =  @SITE
			  AND [d].OPERATORID = @OPERID;
	END

	ELSE IF @SITE = 'CHI'
	BEGIN
		SELECT TOP 1 [d].[shiftflag]
			  ,[d].[siteflag]
			  ,[d].[OPERATORID]
			  ,[OperatorName]
			  ,[OperatorImageURL] as ImageUrl
			  ,[d].[DRILL_ID]
			  ,[CREW]
			  ,[PATTERN_NO] AS [Location]
			  ,[ol].[STARTDATETIME] AS ShiftStart
			  ,[ol].[ENDDATETIME] AS ShiftEnd
			  ,[ot].JOB_TITLE AS Title
			  , NULL AS ShiftCheckList
			  , 30 AS Evaluation
			  , ISNULL([cw].NROFDAYS, 0) AS ConsecutiveWorkDays
		FROM [CHI].[CONOPS_CHI_DRILL_DETAIL_V] [d]
		LEFT JOIN chi.CONOPS_CHI_OPERATOR_DRILL_LOGIN_V [ol]
		ON [d].shiftflag = ol.[SHIFTFLAG]
		   AND [d].[OPERATORID] = [ol].[OPERATORID] AND [d].DRILL_ID = [ol].DRILL_ID
		LEFT JOIN [chi].[CONOPS_CHI_DRILL_OPERATOR_CONSECUTIVE_WORKDAYS_V] [cw]
		ON [d].ShiftIndex = [cw].Shiftindex
		   AND [d].OPERATORID = [cw].OPERID
		LEFT JOIN [dbo].[OPERATOR_TITLE] [ot] WITH(NOLOCK)
		ON [d].OperatorId = [ot].OPERATOR_ID
		WHERE [d].shiftflag = @SHIFT
			  AND [d].siteflag =  @SITE
			  AND [d].OPERATORID = @OPERID;
	END

	ELSE I