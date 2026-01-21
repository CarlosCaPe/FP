
/******************************************************************  
* PROCEDURE	: dbo.Equipment_Truck_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: mbote, 27 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.Equipment_Truck_Get 'CURR', 'MOR', NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {27 Feb 2023}		{mbote}		{Initial Created}}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Equipment_Truck_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX)
)
AS                        
BEGIN      
	DECLARE @SCHEMA VARCHAR(4);
	
	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;

	SET @SCHEMA = CASE @SITE 
					   WHEN 'CMX' THEN 'CLI'
					   ELSE @SITE
				  END;

	--SELECT [shiftflag]
	--	,[siteflag]
	--	,[ShiftId]
	--	,[TruckID]
	--	,[Operator]
	--	,[OperatorImageURL]
	--	,[StatusName] AS [status]
	--	,[ReasonId]
	--	,[ReasonDesc]
	--	,[Payload]
	--	,[PayloadTarget]
	--	,[TotalMaterialDelivered]
	--	,[TotalMaterialDeliveredTarget]
	--	,[DeltaC]
	--	,[DeltaCTarget]
	--	,[IdleTime]
	--	,[IdleTimeTarget]
	--	,[Spotting]
	--	,[SpottingTarget]
	--	,[Loading]
	--	,[LoadingTarget]
	--	,[Dumping]
	--	,[DumpingTarget]
	--	,[DumpsAtStockpile]
	--	,[DumpsAtStockpileTarget]
	--	,[DumpsAtCrusher]
	--	,[DumpsAtCrusherTarget]
	--	,[Location]
	--	,[TonsHaul]
	--	,[TonsHaulTarget]
	--	,[Utilization]
	--	,[EmptyTravel]
	--	,[EmptyTravelTarget]
	--	,[duration]
	--	,[Score]
	--FROM [dbo].[CONOPS_EQMT_TRUCK_MATRIX_V]
	--WHERE shiftflag = @SHIFT
	--AND siteflag = @SITE
	--AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')

	EXEC(' SELECT [shiftflag]
		,[siteflag]
		,[ShiftId]
		,[TruckID]
		,[Operator]
		,[OperatorImageURL]
		,[StatusName] AS [status]
		,[ReasonId]
		,[ReasonDesc]
		,[Payload]
		,[PayloadTarget]
		,[TotalMaterialDelivered]
		,[TotalMaterialDeliveredTarget]
		,[DeltaC]
		,[DeltaCTarget]
		,[IdleTime]
		,[IdleTimeTarget]
		,[Spotting]
		,[SpottingTarget]
		,[Loading]
		,[LoadingTarget]
		,[Dumping]
		,[DumpingTarget]
		,[DumpsAtStockpile]
		,[DumpsAtStockpileTarget]
		,[DumpsAtCrusher]
		,[DumpsAtCrusherTarget]
		,[Location]
		,[TonsHaul]
		,[TonsHaulTarget]
		,[Utilization]
		,[EmptyTravel]
		,[EmptyTravelTarget]
		,[duration]
		,[Score]
	FROM [' + @SCHEMA + '].[CONOPS_' + @SCHEMA + '_EQMT_TRUCK_MATRIX_V]
	WHERE shiftflag = ''' + @SHIFT + '''
	AND siteflag = ''' + @SITE + '''
	AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(''' + @STATUS + ''') , '''','''')) OR ISNULL( ' + @STATUS + ', '') = '') ');

SET NOCOUNT OFF
END