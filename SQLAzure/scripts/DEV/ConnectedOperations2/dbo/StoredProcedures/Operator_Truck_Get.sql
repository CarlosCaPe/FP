
/******************************************************************  
* PROCEDURE	: dbo.Operator_Truck_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: mbote, 26 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.Operator_Truck_Get 'PREV', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Apr 2023}		{mbote}		{Initial Created}
* {04 May 2023}		{mbote}		{Add columns}
* {09 May 2023}		{mbote}		{edit required columns}
* {26 Oct 2023}		{lwasini}	{MVP 8.2 Adjustment}
* {22 Jan 2024}		{lwasini}	{Add TYR}  
* {24 Jan 2024}		{lwasini}	{Add ABR}
* {12 Mar 2025}		{ggosal1}	{Add OperatorReadyHours}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Operator_Truck_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
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
		  [TruckID]
		  ,[Operator]
		  ,[OperatorId]
		  ,[OperatorImageURL]
		  ,[Crew]
		  ,[Location]
		  ,[EqmtStatus]
		  ,[OperatorStatus]
		  ,[ShiftStartDateTime]
		  ,[ShiftEndDateTime]
		  ,[DeltaC]
		  ,[DeltaCTarget]
		  ,[EFH]
		  ,[EFHTarget]
		  ,[AvgUseOfAvailibility] AS AvgUseOfAvailability
		  ,[AvgUseOfAvailibilityTarget] AS AvgUseOfAvailabilityTarget
		  ,TPRH
		  ,NULL TPRHTarget
		  ,TotalMaterialMoved
		  ,TotalMaterialMovedTarget
		  ,FirstHourTons
		  ,LastHourTons
		  ,OperatorReadyHours
		FROM [bag].[CONOPS_BAG_OPERATOR_TRUCK_V]
		WHERE [shiftflag] = @SHIFT
		
	END

	ELSE IF @SITE = 'CER'
	BEGIN
		SELECT 
		  [TruckID]
		  ,[Operator]
		  ,[OperatorId]
		  ,[OperatorImageURL]
		  ,[Crew]
		  ,[Location]
		  ,[EqmtStatus]
		  ,[OperatorStatus]
		  ,[ShiftStartDateTime]
		  ,[ShiftEndDateTime]
		  ,[DeltaC]
		  ,[DeltaCTarget]
		  ,[EFH]
		  ,[EFHTarget]
		  ,[AvgUseOfAvailibility] AS AvgUseOfAvailability
		  ,[AvgUseOfAvailibilityTarget] AS AvgUseOfAvailabilityTarget
		  ,TPRH
		  ,NULL TPRHTarget
		  ,TotalMaterialMoved
		  ,TotalMaterialMovedTarget
		  ,FirstHourTons
		  ,LastHourTons
		  ,OperatorReadyHours
		FROM [cer].[CONOPS_CER_OPERATOR_TRUCK_V]
		WHERE [shiftflag] = @SHIFT
		
	END

	ELSE IF @SITE = 'CHI'
	BEGIN
		SELECT 
		  [TruckID]
		  ,[Operator]
		  ,[OperatorId]
		  ,[OperatorImageURL]
		  ,[Crew]
		  ,[Location]
		  ,[EqmtStatus]
		  ,[OperatorStatus]
		  ,[ShiftStartDateTime]
		  ,[ShiftEndDateTime]
		  ,[DeltaC]
		  ,[DeltaCTarget]
		  ,[EFH]
		  ,[EFHTarget]
		  ,[AvgUseOfAvailibility] AS AvgUseOfAvailability
		  ,[AvgUseOfAvailibilityTarget] AS AvgUseOfAvailabilityTarget
		  ,TPRH
		  ,NULL TPRHTarget
		  ,TotalMaterialMoved
		  ,TotalMaterialMovedTarget
		  ,FirstHourTons
		  ,LastHourTons
		  ,OperatorReadyHours
		FROM [chi].[CONOPS_CHI_OPERATOR_TRUCK_V]
		WHERE [shiftflag] = @SHIFT
		
	END

	ELSE IF @SITE = 'CMX'
	BEGIN
		SELECT 
		  [TruckID]
		  ,[Operator]
		  ,[OperatorId]
		  ,[OperatorImageURL]
		  ,[Crew]
		  ,[Location]
		  ,[EqmtStatus]
		  ,[OperatorStatus]
		  ,[ShiftStartDateTime]
		  ,[ShiftEndDateTime]
		  ,[DeltaC]
		  ,[DeltaCTarget]
		  ,[EFH]
		  ,[EFHTarget]
		  ,[AvgUseOfAvailibility] AS AvgUseOfAvailability
		  ,[AvgUseOfAvailibilityTarget] AS AvgUseOfAvailabilityTarget
		  ,TPRH
		  ,NULL TPRHTarget
		  ,TotalMaterialMoved
		  ,TotalMaterialMovedTarget
		  ,FirstHourTons
		  ,LastHourTons
		  ,OperatorReadyHours
		FROM [cli].[CONOPS_CLI_OPERATOR_TRUCK_V]
		WHERE [shiftflag] = @SHIFT
		
	END

	ELSE IF @SITE = 'MOR'
	BEGIN
		SELECT 
		  [TruckID]
		  ,[Operator]
		  ,[OperatorId]
		  ,[OperatorImageURL]
		  ,[Crew]
		  ,[Location]
		  ,[EqmtStatus]
		  ,[OperatorStatus]
		  ,[ShiftStartDateTime]
		  ,[ShiftEndDateTime]
		  ,[DeltaC]
		  ,[DeltaCTarget]
		  ,[EFH]
		  ,[EFHTarget]
		  ,[AvgUseO