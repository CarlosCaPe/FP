

/******************************************************************  
* PROCEDURE	: dbo.Operator_TruckDetail_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: mbote, 09 May 2023
* SAMPLE	: 
	1. EXEC dbo.Operator_TruckDetail_Get 'CURR', 'BAG', '61011336'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {09 May 2023}		{mbote}		{Initial Created}
* {09 May 2023}		{mbote}		{Data for overview only} 
* {27 Oct 2023}		{lwasini}	{Simplify Query}
* {22 Jan 2024}		{lwasini}	{Add TYR}
* {24 Jan 2024}		{lwasini}	{Add ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Operator_TruckDetail_Get] 
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
		SELECT
			[shift].SHIFTSTARTDATETIME,
			[shift].SHIFTENDDATETIME,
			[tl].Operator,
			[tl].OperatorId,
			[tl].OperatorImageURL,
			[tl].TruckID,
			[tl].CrewName AS Crew,
			[tl].[Location],
			[ot].JOB_TITLE AS Title,
			ISNULL([ocw].NrOfDays, 0) AS ConsecutiveWorkDays,
			NULL AS ShiftCheckList,
			30 AS Evaluation
		FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] [shift]
		LEFT JOIN [bag].[CONOPS_BAG_OPERATOR_TRUCK_LIST_V] [tl]
		ON [shift].shiftflag = [tl].shiftflag
		LEFT JOIN [dbo].[OPERATOR_TITLE] [ot] WITH (NOLOCK)
		ON RIGHT('0000000000' + [tl].OperatorId, 10) = [ot].OPERATOR_ID
		AND [ot].SITE_CODE = 'BAG'
		LEFT JOIN [dbo].[OPERATOR_CONSECUTIVE_WORKDAYS] [ocw] WITH (NOLOCK)  
		ON [tl].ShiftIndex = [ocw].LastShiftIndex  
		AND RIGHT('0000000000' + [tl].[OperatorId], 10) = [ocw].OperId  
		AND [ocw].SITE_CODE = 'BAG'
		WHERE [shift].SHIFTFLAG = @SHIFT
		AND [tl].OperatorId = @OPERID;
	END

	ELSE IF @SITE = 'CER'
	BEGIN
		SELECT
			[shift].SHIFTSTARTDATETIME,
			[shift].SHIFTENDDATETIME,
			[tl].Operator,
			[tl].OperatorId,
			[tl].OperatorImageURL,
			[tl].TruckID,
			[tl].CrewName AS Crew,
			[tl].[Location],
			[ot].JOB_TITLE AS Title,
			ISNULL([ocw].NrOfDays, 0) AS ConsecutiveWorkDays,
			NULL AS ShiftCheckList,
			30 AS Evaluation
		FROM [cer].[CONOPS_CER_SHIFT_INFO_V] [shift]
		LEFT JOIN [cer].[CONOPS_CER_OPERATOR_TRUCK_LIST_V] [tl]
		ON [shift].shiftflag = [tl].shiftflag
		LEFT JOIN [dbo].[OPERATOR_TITLE] [ot] WITH (NOLOCK)
		ON RIGHT('0000000000' + [tl].OperatorId, 10) = [ot].OPERATOR_ID
		AND [ot].SITE_CODE = 'CER'
		LEFT JOIN [dbo].[OPERATOR_CONSECUTIVE_WORKDAYS] [ocw] WITH (NOLOCK)  
		ON [tl].ShiftIndex = [ocw].LastShiftIndex  
		AND RIGHT('0000000000' + [tl].[OperatorId], 10) = [ocw].OperId  
		AND [ocw].SITE_CODE = 'CER'
		WHERE [shift].SHIFTFLAG = @SHIFT
		AND [tl].OperatorId = @OPERID;
	END

	ELSE IF @SITE = 'CHI'
	BEGIN
		SELECT
			[shift].SHIFTSTARTDATETIME,
			[shift].SHIFTENDDATETIME,
			[tl].Operator,
			[tl].OperatorId,
			[tl].OperatorImageURL,
			[tl].TruckID,
			[tl].CrewName AS Crew,
			[tl].[Location],
			[ot].JOB_TITLE AS Title,
			ISNULL([ocw].NrOfDays, 0) AS ConsecutiveWorkDays,
			NULL AS ShiftCheckList,
			30 AS Evaluation
		FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] [shift]
		LEFT JOIN [chi].[CONOPS_CHI_OPERATOR_TRUCK_LIST_V] [tl]
		ON [shift].shiftflag = [tl].shiftflag
		LEFT JOIN [dbo].[OPERATOR_TITLE] [ot] WITH (NOLOCK)
		ON RIGHT('0000000000' + [tl].OperatorId, 10) = [ot].OPERATOR_ID
		AND [ot].SITE_CODE = 'CHI'
		LEFT JOIN [dbo].[OPERATOR_CONSECUTIVE_WORKDAYS] [ocw] WITH (NOLOCK)  
		ON [tl].ShiftIndex = [ocw].LastShiftIndex  
		AND RIGHT('0000000000' + [tl].[OperatorId], 10) = [ocw].OperId  
		AND [ocw].SITE_CODE = 'CHI'
		WHERE [shift].SHIFTFLAG = @SHIFT
		AND [tl].OperatorId = @OPERID;
	END

	ELSE IF @SITE = 'CMX'
	BEGIN
		SELECT
			[shift].SHIFTSTARTDATETIME,
			[shift].SHIFTENDDATETIME,
			[tl].Operator,
			[tl].