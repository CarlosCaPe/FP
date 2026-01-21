




/******************************************************************  
* PROCEDURE	: dbo.EOS_DeltaJ_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 19 May 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_DeltaJ_Get 'CURR', 'MOR',1
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {19 May 2023}		{ggosal1}		{Initial Created} 
* {18 Jul 2023}		{lwasini}		{Added Total Delta J} 
* {08 Aug 2023}		{lwasini}		{Update Delta J} 
* {09 Aug 2023}		{lwasini}		{Added ShiftStartDateTime & ShiftEndDateTime} 
* {11 Oct 2023}		{lwasini}	   	{Exclude 0 on TotalDeltaJ}
* {06 Dec 2023}		{lwasini}	   	{Add Daily Summary}
* {30 Jan 2024}		{lwasini}		{Add TYR & ABR} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_DeltaJ_Get] 
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
			ROUND(AVG(DeltaJ),0) TotalDeltaJ
		FROM [bag].[CONOPS_BAG_DELTA_J_V] 
		WHERE shiftflag = @SHIFT
		AND DeltaJ <> 0;

		SELECT 
			TimeinHour,
			DeltaJ,
			ShiftStartDateTime,
			ShiftEndDateTime
		FROM [bag].[CONOPS_BAG_DELTA_J_V] 
		WHERE DeltaJ IS NOT NULL
		AND shiftflag = @SHIFT;
		

		--DrillDown
		SELECT
			TimeinHour,
			ROUND(SUM(TotalMaterialMined/1000.0),1) AS Tons,
			ISNULL(ROUND(SUM(TotalMaterialMinedTarget/1000.0),1),0) TonsTarget,
			ROUND(AVG(UofA),0) AS UseOfAvailability,
			UseOfAvailabilityTarget,
			ROUND(AVG(EFH),0) AS EquivalentFlatHaul,
			EFHTarget AS EquivalentFlatHaulTarget
		FROM [bag].[CONOPS_BAG_DELTA_J_V] a
		INNER JOIN [bag].[CONOPS_BAG_HOURLY_TRUCK_ASSET_EFFICIENCY_V] b
		ON a.shiftflag = b.shiftflag AND a.TimeinHour = b.Hr
		CROSS JOIN (
		SELECT TOP 1
			TRUCKUSEOFAVAILABILITY as useOfAvailabilityTarget
		FROM [bag].[plan_values_prod_sum] WITH (NOLOCK)
		ORDER BY EffectiveDate DESC) c
		WHERE b.eqmtunit = 2
		AND a.shiftflag = @SHIFT
		GROUP BY TimeinHour,UseOfAvailabilityTarget,EFHTarget;
		END


		ELSE IF @DAILY = 1
		BEGIN
		SELECT 
			ROUND(AVG(DeltaJ),0) TotalDeltaJ
		FROM [bag].[CONOPS_BAG_DAILY_DELTA_J_V] 
		WHERE shiftflag = @SHIFT
		AND DeltaJ <> 0;

		SELECT DISTINCT
			TimeinHour,
			DeltaJ,
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS ShiftStartDateTime,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime DESC) AS ShiftEndDateTime
		FROM [bag].[CONOPS_BAG_DAILY_DELTA_J_V] 
		WHERE DeltaJ IS NOT NULL
		AND shiftflag = @SHIFT;
		

		--DrillDown
		SELECT
			TimeinHour,
			ROUND(SUM(TotalMaterialMined/1000.0),1) AS Tons,
			ISNULL(ROUND(SUM(TotalMaterialMinedTarget/1000.0),1),0) TonsTarget,
			ROUND(AVG(UofA),0) AS UseOfAvailability,
			UseOfAvailabilityTarget,
			ROUND(AVG(EFH),0) AS EquivalentFlatHaul,
			EFHTarget AS EquivalentFlatHaulTarget
		FROM [bag].[CONOPS_BAG_DAILY_DELTA_J_V] a
		INNER JOIN [bag].[CONOPS_BAG_DAILY_HOURLY_TRUCK_ASSET_EFFICIENCY_V] b
		ON a.shiftflag = b.shiftflag AND a.TimeinHour = b.Hr
		CROSS JOIN (
		SELECT TOP 1
			TRUCKUSEOFAVAILABILITY as useOfAvailabilityTarget
		FROM [bag].[plan_values_prod_sum] WITH (NOLOCK)
		ORDER BY EffectiveDate DESC) c
		WHERE b.eqmtunit = 2
		AND a.shiftflag = @SHIFT
		GROUP BY TimeinHour,UseOfAvailabilityTarget,EFHTarget;
		END


	END

	ELSE IF @SITE = 'CVE'
	BEGIN
		
		IF @DAILY = 0
		BEGIN
		SELECT 
			ROUND(AVG(DeltaJ),0) TotalDeltaJ
		FROM [cer].[CONOPS_CER_DELTA_J_V] 
		WHERE shiftflag = @SHIFT
		AND DeltaJ <> 0;


		SELECT 
			TimeinHour,
			DeltaJ,
			ShiftStartDateTime,
			ShiftEndDateTime
		FROM [cer].[CONOPS_CER_DELTA_J_V] 
		WHERE DeltaJ IS NOT NULL
		AND shiftflag = @SHIFT;

		--DrillDown
		SELECT
			TimeinHour,
			ROUND(SUM(TotalMaterialMined/1000.0),1) AS Tons,
			ISNULL(ROUND(SUM(TotalMaterialMinedTarget/1000.0),1),0) TonsTarget,
			ROUND(AVG(Uof