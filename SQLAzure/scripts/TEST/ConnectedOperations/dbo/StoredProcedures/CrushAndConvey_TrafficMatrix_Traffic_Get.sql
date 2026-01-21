







/******************************************************************  
* PROCEDURE	: dbo.CrushAndConvey_TrafficMatrix_Traffic_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 14 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.CrushAndConvey_TrafficMatrix_Traffic_Get 'CURR', 'BAG'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {14 Jun 2023}		{jrodulfa}		{Initial Created}  
* {19 Oct 2023}		{lwasini}		{Add PushbackId} 
* {15 Nov 2023}		{ggosal1}		{Add Order by Status} 
* {30 Jan 2024}		{lwasini}		{Add TYR & ABR} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CrushAndConvey_TrafficMatrix_Traffic_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	IF @SITE = 'BAG'
	BEGIN

		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[TrafficType]
			  ,[LocationID]
			  ,[Status]
			  ,[TruckID]
			  ,[IsTruckAtLocation]
			  ,CASE WHEN [IsTruckAtLocation] = 0 AND 
						 [TruckID] IS NOT NULL
					THEN ROUND(SQRT([dx] * [dx] + [dy] * [dy]) / IIF ((Velocity IS NOT NULL AND Velocity != 0), Velocity, 1 ),1)
					ELSE NULL
			   END MinAway
			   ,PushbackId
		FROM [bag].[CONOPS_BAG_TM_TRAFFIC_LOADER_V]
		WHERE [SHIFTFLAG] = @SHIFT
		ORDER BY 
		CASE WHEN Status = 'Ready' THEN 1
			WHEN Status = 'Delay' THEN 2
			WHEN Status = 'Spare' THEN 3
			WHEN Status = 'Down' THEN 4
		ELSE 5 END ASC;

		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[TrafficType]
			  ,[LocationID]
			  ,[Status]
			  ,[TruckID]
			  ,[IsTruckAtLocation]
			  ,CASE WHEN [IsTruckAtLocation] = 0 AND 
						 [TruckID] IS NOT NULL
					THEN ROUND(SQRT([dx] * [dx] + [dy] * [dy]) / IIF ((Velocity IS NOT NULL AND Velocity != 0), Velocity, 1 ),1)
					ELSE NULL
			   END MinAway
			   ,PushbackId
		FROM [bag].[CONOPS_BAG_TM_TRAFFIC_SHOVEL_V]
		WHERE [SHIFTFLAG] = @SHIFT
		ORDER BY 
		CASE WHEN Status = 'Ready' THEN 1
			WHEN Status = 'Delay' THEN 2
			WHEN Status = 'Spare' THEN 3
			WHEN Status = 'Down' THEN 4
		ELSE 5 END ASC;

		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[TrafficType]
			  ,[LocationID]
			  ,[Status]
			  ,[TruckID]
			  ,[IsTruckAtLocation]
			  ,CASE WHEN [IsTruckAtLocation] = 0 AND 
						 [TruckID] IS NOT NULL
					THEN ROUND(SQRT([dx] * [dx] + [dy] * [dy]) / IIF ((Velocity IS NOT NULL AND Velocity != 0), Velocity, 1 ),1)
					ELSE NULL
			   END MinAway
			   ,PushbackId
		FROM [bag].[CONOPS_BAG_TM_TRAFFIC_CRUSHER_V]
		WHERE [SHIFTFLAG] = @SHIFT
		ORDER BY 
		CASE WHEN Status = 'Ready' THEN 1
			WHEN Status = 'Delay' THEN 2
			WHEN Status = 'Spare' THEN 3
			WHEN Status = 'Down' THEN 4
		ELSE 5 END ASC;

		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[TrafficType]
			  ,[LocationID]
			  ,[Status]
			  ,[TruckID]
			  ,[IsTruckAtLocation]
			  ,CASE WHEN [IsTruckAtLocation] = 0 AND 
						 [TruckID] IS NOT NULL
					THEN ROUND(SQRT([dx] * [dx] + [dy] * [dy]) / IIF ((Velocity IS NOT NULL AND Velocity != 0), Velocity, 1 ),1)
					ELSE NULL
			   END MinAway
			   ,PushbackId
		FROM [bag].[CONOPS_BAG_TM_TRAFFIC_STOCKPILE_V]
		WHERE [SHIFTFLAG] = @SHIFT
		ORDER BY 
		CASE WHEN Status = 'Ready' THEN 1
			WHEN Status = 'Delay' THEN 2
			WHEN Status = 'Spare' THEN 3
			WHEN Status = 'Down' THEN 4
		ELSE 5 END ASC;
	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[TrafficType]
			  ,[LocationID]
			  ,[Status]
			  ,[TruckID]
			  ,[IsTruckAtLocation]
			  ,CASE WHEN [IsTruckAtLocation] = 0 AND 
						 [TruckID] IS NOT NULL
					THEN ROUND(SQRT([dx] * [dx] + [dy] * [dy]) / IIF ((Velocity IS NOT NULL AND Velocity != 0), Velocity, 1 ),1)
					ELSE NULL
			   END MinAway
			   ,PushbackId
		FROM [cer].[CONOPS_CER_TM_TRAFFIC_LOADER_V]
		WHERE [SHIFTFLAG] = @SHIFT
		ORDER BY 
		CASE WHEN Status = 'Ready' THEN 1
			WHEN Status = 'Delay' THEN 2
			WHEN Status 