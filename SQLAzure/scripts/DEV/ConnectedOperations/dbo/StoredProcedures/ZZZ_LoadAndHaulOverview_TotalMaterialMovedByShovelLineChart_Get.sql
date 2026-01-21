


/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_TotalMaterialMovedByShovelLineChart_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Jul 2023
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_TotalMaterialMovedByShovelLineChart_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Jul 2023}		{lwasini}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[ZZZ_LoadAndHaulOverview_TotalMaterialMovedByShovelLineChart_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	IF @SITE = 'BAG'
	BEGIN

		SELECT 
			[DateTime],
			ROUND(TotalMaterialMoved/1000.0,1) AS [Value],
			ROUND([target]/1000.0,1) AS [Target],
			ROUND(shifttarget/1000.0,1) AS ShiftTarget,
			ShiftStartDateTime AS StartDate,
			ShiftEndDateTime AS EndDate
		FROM BAG.[CONOPS_BAG_TONS_LINE_GRAPH_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY [DateTime] DESC

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
			[DateTime],
			ROUND(TotalMaterialMoved/1000.0,1) AS [Value],
			ROUND([target]/1000.0,1) AS [Target],
			ROUND(shifttarget/1000.0,1) AS ShiftTarget,
			ShiftStartDateTime AS StartDate,
			ShiftEndDateTime AS EndDate
		FROM [cer].[CONOPS_CER_TONS_LINE_GRAPH_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY [DateTime] DESC

	END

	ELSE IF @SITE = 'CHN'
	BEGIN
		
		SELECT 
			[DateTime],
			ROUND(TotalMaterialMoved/1000.0,1) AS [Value],
			ROUND([target]/1000.0,1) AS [Target],
			ROUND(shifttarget/1000.0,1) AS ShiftTarget,
			ShiftStartDateTime AS StartDate,
			ShiftEndDateTime AS EndDate
		FROM [chi].[CONOPS_CHI_TONS_LINE_GRAPH_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY [DateTime] DESC

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT 
			[DateTime],
			ROUND(TotalMaterialMoved/1000.0,1) AS [Value],
			ROUND([target]/1000.0,1) AS [Target],
			ROUND(shifttarget/1000.0,1) AS ShiftTarget,
			ShiftStartDateTime AS StartDate,
			ShiftEndDateTime AS EndDate
		FROM CLI.[CONOPS_CLI_TONS_LINE_GRAPH_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY [DateTime] DESC

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT 
			[DateTime],
			ROUND(TotalMaterialMoved/1000.0,1) AS [Value],
			ROUND([target]/1000.0,1) AS [Target],
			ROUND(shifttarget/1000.0,1) AS ShiftTarget,
			ShiftStartDateTime AS StartDate,
			ShiftEndDateTime AS EndDate
		FROM [mor].[CONOPS_MOR_TONS_LINE_GRAPH_V]
		WHERE shiftflag = @SHIFT
		ORDER BY [DateTime] DESC

	END

	ELSE IF @SITE = 'SAM'
	BEGIN

		SELECT 
			[DateTime],
			ROUND(TotalMaterialMoved/1000.0,1) AS [Value],
			ROUND([target]/1000.0,1) AS [Target],
			ROUND(shifttarget/1000.0,1) AS ShiftTarget,
			ShiftStartDateTime AS StartDate,
			ShiftEndDateTime AS EndDate
		FROM SAF.[CONOPS_SAF_TONS_LINE_GRAPH_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY [DateTime] DESC

	END

	ELSE IF @SITE = 'SIE'
	BEGIN

		SELECT 
			[DateTime],
			ROUND(TotalMaterialMoved/1000.0,1) AS [Value],
			ROUND([target]/1000.0,1) AS [Target],
			ROUND(shifttarget/1000.0,1) AS ShiftTarget,
			ShiftStartDateTime AS StartDate,
			ShiftEndDateTime AS EndDate
		FROM [sie].[CONOPS_SIE_TONS_LINE_GRAPH_V]  (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY [DateTime] DESC

	END

END


