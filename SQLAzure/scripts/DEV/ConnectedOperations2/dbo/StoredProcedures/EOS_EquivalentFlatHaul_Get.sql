









/******************************************************************  
* PROCEDURE	: dbo.EOS_EquivalentFlatHaul_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 19 May 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_EquivalentFlatHaul_Get 'CURR', 'MOR',1
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {19 May 2023}		{ggosal1}		{Initial Created} 
* {04 Aug 2023}		{ggosal1}	   	{Applied new EFH}
* {21 Sep 2023}		{lwasini}	   	{Exclude 0 on OverallEFH}
* {04 Dec 2023}		{lwasini}	   	{Add Daily Summary}
* {06 Apr 2024}		{ggosal1}	   	{Change Hourly Overall EFH to ShiftEFH for ALL SITE}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_EquivalentFlatHaul_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@DAILY INT
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN
		
		IF @DAILY = 0
		BEGIN
		SELECT
			AVG(EFHShiftTarget) AS ShiftTarget,
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS StartDate,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime ASC) AS EndDate,
			AVG(ShiftEFH) AS OverallEfh
		FROM [BAG].[CONOPS_BAG_EFH_V]
		WHERE shiftflag = @SHIFT
		AND EFH <> 0
		GROUP BY ShiftStartDateTime, ShiftEndDateTime
 
		SELECT
			EFH AS [Value], 
			BreakByHour AS DateTime
		FROM [BAG].[CONOPS_BAG_EFH_V]
		WHERE shiftflag = @SHIFT
		ORDER BY BreakByHour DESC;
		END

		ELSE IF @DAILY = 1
		BEGIN
		
		SELECT
		ShiftTarget,
		StartDate,
		EndDate,
		AVG(OverallEfh) OverallEfh
		FROM (
		SELECT
			AVG(EFHShiftTarget) AS ShiftTarget,
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS StartDate,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime DESC) AS EndDate,
			AVG(ShiftEFH) AS OverallEfh
		FROM [BAG].[CONOPS_BAG_DAILY_EFH_V]
		WHERE shiftflag = @SHIFT
		AND EFH <> 0
		GROUP BY ShiftStartDateTime, ShiftEndDateTime) x
		GROUP BY ShiftTarget, StartDate, EndDate
 
		SELECT DISTINCT
			EFH AS [Value], 
			BreakByHour AS DateTime
		FROM [BAG].[CONOPS_BAG_DAILY_EFH_V]
		WHERE shiftflag = @SHIFT
		ORDER BY BreakByHour DESC;
		END

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		IF @DAILY = 0
		BEGIN
		SELECT
			AVG(EFHShiftTarget) AS ShiftTarget,
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS StartDate,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime ASC) AS EndDate,
			AVG(ShiftEFH) AS OverallEfh
		FROM [CER].[CONOPS_CER_EFH_V]
		WHERE shiftflag = @SHIFT
		AND EFH <> 0
		GROUP BY ShiftStartDateTime, ShiftEndDateTime
 
		SELECT
			EFH AS [Value], 
			BreakByHour AS DateTime
		FROM [CER].[CONOPS_CER_EFH_V]
		WHERE shiftflag = @SHIFT
		ORDER BY BreakByHour DESC;
		END

		ELSE IF @DAILY = 1
		BEGIN

		SELECT
		ShiftTarget,
		StartDate,
		EndDate,
		AVG(OverallEfh) OverallEfh
		FROM (
		SELECT
			AVG(EFHShiftTarget) AS ShiftTarget,
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS StartDate,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime DESC) AS EndDate,
			AVG(ShiftEFH) AS OverallEfh
		FROM [CER].[CONOPS_CER_DAILY_EFH_V]
		WHERE shiftflag = @SHIFT
		AND EFH <> 0
		GROUP BY ShiftStartDateTime, ShiftEndDateTime) x
		GROUP BY ShiftTarget, StartDate, EndDate
 
		SELECT DISTINCT
			EFH AS [Value], 
			BreakByHour AS DateTime
		FROM [CER].[CONOPS_CER_DAILY_EFH_V]
		WHERE shiftflag = @SHIFT
		ORDER BY BreakByHour DESC;
		END

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		IF @DAILY = 0
		BEGIN
		SELECT
			AVG(EFHShiftTarget) AS ShiftTarget,
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS StartDate,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime ASC) AS EndDate,
			AVG(ShiftEFH) AS OverallEfh
		FROM [CHI].[CONOPS_CHI_EFH_V]
		WHERE shiftflag = @SHIFT
		AND EFH