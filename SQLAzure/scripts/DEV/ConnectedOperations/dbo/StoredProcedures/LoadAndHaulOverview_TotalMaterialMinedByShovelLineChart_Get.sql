

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_TotalMaterialMinedByShovelLineChart_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_TotalMaterialMinedByShovelLineChart_Get 'CURR', 'BAG', NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created} 
* {07 Dec 2022}		{sxavier}		{Initial Created} 
* {27 Nov 2023}		{lwasini}		{MVP 8.3} 
* {27 Dec 2023}		{lwasini}		{Add Total} 
* {12 Jan 2024}		{lwasini}		{Add TYR} 
* {23 Jan 2024}		{lwasini}		{Add ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TotalMaterialMinedByShovelLineChart_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@MTRL VARCHAR(20)
)
AS

IF (@MTRL IS NULL)
BEGIN
	SET @MTRL = 'All'
END

BEGIN

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT TOP 1
			ROUND(MAX(TotalMined)/1000.0,1) AS [Total],
			ROUND(MAX(shifttarget)/1000.0,1) AS ShiftTarget
		FROM [BAG].[CONOPS_BAG_TONS_LINE_GRAPH_V]
		CROSS APPLY (VALUES ('Mill', Mill),
					('ROM', ROM),
					('Waste', Waste),
					('Crush Leach',CrushLeach),
					('All', Actual))
		CrossApplied (MaterialMined, TotalMined)
		WHERE shiftflag = @SHIFT
		AND MaterialMined = @MTRL
		GROUP BY DateTime
		ORDER BY DateTime DESC;
	
		SELECT 
			TimeInHour AS [DateTime],
			ROUND(TotalMined/1000.0,1) AS [Value],
			ROUND([target]/1000.0,1) AS [Target],
			ROUND(shifttarget/1000.0,1) AS ShiftTarget,
			ShiftStartDateTime AS StartDate,
			ShiftEndDateTime AS EndDate
		FROM (
		SELECT 
		shiftflag, 
		TimeInHour, 
		ShiftTarget, 
		[Target],
		ShiftStartDateTime,
		ShiftEndDateTime,
		MaterialMined,
		ISNULL(TotalMined,0) TotalMined
		FROM [BAG].[CONOPS_BAG_HOURLY_TOTALMATERIALMINED_V] 
		CROSS APPLY (VALUES ('Mill', Mill),
					('ROM', ROM),
					('Waste', Waste),
					('Crush Leach',CrushLeach),
					('All', TotalMaterialMined))
		CrossApplied (MaterialMined, TotalMined)
		) a
		WHERE shiftflag = @SHIFT
		AND MaterialMined = @MTRL
		ORDER BY TimeInHour DESC;
	
		SELECT 
			[DateTime],
			ROUND(TotalMined/1000.0,1) AS [Value],
			ROUND([target]/1000.0,1) AS [Target],
			ROUND(shifttarget/1000.0,1) AS ShiftTarget,
			ShiftStartDateTime AS StartDate,
			ShiftEndDateTime AS EndDate
		FROM (
		SELECT
			shiftflag,
			DateTime,
			[Target],
			ShiftTarget,
			ShiftStartDateTime,
			ShiftEndDateTime,
			MaterialMined,
			TotalMined
		FROM [BAG].[CONOPS_BAG_TONS_LINE_GRAPH_V] 
		CROSS APPLY (VALUES ('Mill', Mill),
					('ROM', ROM),
					('Waste', Waste),
					('Crush Leach',CrushLeach),
					('All', Actual))
		CrossApplied (MaterialMined, TotalMined)
		) a
		WHERE shiftflag = @SHIFT
		AND MaterialMined = @MTRL
		ORDER BY DateTime DESC;

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT TOP 1
			ROUND(MAX(TotalMined)/1000.0,1) AS [Total],
			ROUND(MAX(shifttarget)/1000.0,1) AS ShiftTarget
		FROM [CER].[CONOPS_CER_TONS_LINE_GRAPH_V]
		CROSS APPLY (VALUES ('Mill', Mill),
					('ROM', ROM),
					('Waste', Waste),
					('Crush Leach',CrushLeach),
					('All', Actual))
		CrossApplied (MaterialMined, TotalMined)
		WHERE shiftflag = @SHIFT
		AND MaterialMined = @MTRL
		GROUP BY DateTime
		ORDER BY DateTime DESC;
	
		SELECT 
			TimeInHour AS [DateTime],
			ROUND(TotalMined/1000.0,1) AS [Value],
			ROUND([target]/1000.0,1) AS [Target],
			ROUND(shifttarget/1000.0,1) AS ShiftTarget,
			ShiftStartDateTime AS StartDate,
			ShiftEndDateTime AS EndDate
		FROM (
		SELECT 
		shiftflag, 
		TimeInHour, 
		ShiftTarget, 
		[Target],
		ShiftStartDateTime,
		ShiftEndDateTime,
		MaterialMined,
		ISNULL(TotalMined,0) TotalMined
		FROM [CER].[CONOPS_CER_HOURLY_TOTALMATERIALMINED_V] 
		CROSS APPLY (VALUES ('Mill', Mill),
					('ROM', ROM),