






/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_EquivalentFlatHaul_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_EquivalentFlatHaul_Get 'CURR', 'BAG'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created} 
* {21 Nov 2022}		{sxavier}		{Refactor query}  
* {14 Feb 2023}		{sxavier}	   	{Remove field Target.}
* {04 Aug 2023}		{ggosal1}	   	{Applied new EFH}
* {21 Sep 2023}		{lwasini}	   	{Exclude 0 from OverallEFH}
* {15 Nov 2023}		{ggosal1}	   	{Remove EFH <> 0 filter afer updating the view}
* {06 Apr 2024}		{ggosal1}	   	{Change Hourly Overall EFH to ShiftEFH for ALL SITE}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_EquivalentFlatHaul_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	IF @SITE = 'BAG'
	BEGIN

		SELECT
			AVG(EFHShiftTarget) AS ShiftTarget,
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS StartDate,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime ASC) AS EndDate,
			AVG(ShiftEFH) AS OverallEfh
		FROM [BAG].[CONOPS_BAG_EFH_V]
		WHERE shiftflag = @SHIFT
		--AND EFH <> 0
		GROUP BY ShiftStartDateTime, ShiftEndDateTime
 
		SELECT
			EFH AS [Value], 
			BreakByHour AS DateTime
		FROM [BAG].[CONOPS_BAG_EFH_V]
		WHERE shiftflag = @SHIFT
		ORDER BY BreakByHour DESC

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			AVG(EFHShiftTarget) AS ShiftTarget,
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS StartDate,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime ASC) AS EndDate,
			AVG(ShiftEFH) AS OverallEfh
		FROM [CER].[CONOPS_CER_EFH_V]
		WHERE shiftflag = @SHIFT
		--AND EFH <> 0
		GROUP BY ShiftStartDateTime, ShiftEndDateTime
 
		SELECT
			EFH AS [Value], 
			BreakByHour AS DateTime
		FROM [CER].[CONOPS_CER_EFH_V]
		WHERE shiftflag = @SHIFT
		ORDER BY BreakByHour DESC

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT
			AVG(EFHShiftTarget) AS ShiftTarget,
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS StartDate,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime ASC) AS EndDate,
			AVG(ShiftEFH) AS OverallEfh
		FROM [CHI].[CONOPS_CHI_EFH_V]
		WHERE shiftflag = @SHIFT
		--AND EFH <> 0
		GROUP BY ShiftStartDateTime, ShiftEndDateTime
 
		SELECT
			EFH AS [Value], 
			BreakByHour AS DateTime
		FROM [CHI].[CONOPS_CHI_EFH_V]
		WHERE shiftflag = @SHIFT
		ORDER BY BreakByHour DESC

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT
			AVG(EFHShiftTarget) AS ShiftTarget,
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS StartDate,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime ASC) AS EndDate,
			AVG(ShiftEFH) AS OverallEfh
		FROM [CLI].[CONOPS_CLI_EFH_V]
		WHERE shiftflag = @SHIFT
		--AND EFH <> 0
		GROUP BY ShiftStartDateTime, ShiftEndDateTime
 
		SELECT
			EFH AS [Value], 
			BreakByHour AS DateTime
		FROM [CLI].[CONOPS_CLI_EFH_V]
		WHERE shiftflag = @SHIFT
		ORDER BY BreakByHour DESC

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT
			AVG(EFHShiftTarget) AS ShiftTarget,
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS StartDate,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime ASC) AS EndDate,
			AVG(ShiftEFH) AS OverallEfh
		FROM [MOR].[CONOPS_MOR_EFH_V]
		WHERE shiftflag = @SHIFT
		--AND EFH <> 0
		GROUP BY ShiftStartDateTime, ShiftEndDateTime
 
		SELECT
			EFH AS [Value], 
			BreakByHour AS DateTime
		FROM [MOR].[CONOPS_MOR_EFH_V]
		WHERE shiftflag = @SHIFT
		ORDER BY BreakByHour DESC

	END

	ELSE IF @SITE = 'SAM'
	BEGIN

		SELECT