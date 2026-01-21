
/******************************************************************  
* PROCEDURE	: dbo.Equipment_Truck_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: mbote, 27 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.Equipment_TruckDrillDown_Get 'PREV', 'MOR', 'READY', 'T500'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {15 March 2023}		{mbote}		{Initial Created}}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Equipment_TruckDrillDown_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS VARCHAR(MAX),
	@TRUCK NVARCHAR(MAX)
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

	EXEC('
		SELECT [shiftflag]
			,[siteflag]
			,[Equipment]
			,[Hr]
			,[Ae]
		FROM [' + @SCHEMA + '].[CONOPS_' + @SCHEMA + '_HOURLY_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag = ''' + @SHIFT + '''
		AND siteflag = ''' + @SITE + '''
		AND [Equipment] = '''+ @TRUCK +'''
		AND [EqmtUnit] = 1
	');

	EXEC(' 
		SELECT [shiftflag]
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
		FROM [' + @SCHEMA + '].[CONOPS_' + @SCHEMA + '_EQMT_TRUCK_V]
		WHERE shiftflag = ''' + @SHIFT + '''
		AND siteflag = ''' + @SITE + '''
		AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(''' + @STATUS + '''), '','')) OR ISNULL(''' + @STATUS + ''', '''') = '''') 
		AND [TruckID] = '''+ @TRUCK +'''
	');

SET NOCOUNT OFF
END