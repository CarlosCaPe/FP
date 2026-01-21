



/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_DeltaJ_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 26 April 2023
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_DeltaJ_Get 'PREV', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Apr 2023}		{lwasini}		{Initial Created} 
* {18 Jul 2023}		{lwasini}		{Added Total Delta J} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[zzz_LoadAndHaulOverview_DeltaJ_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	IF @SITE = 'BAG'
	BEGIN

		SELECT 
			ROUND(AVG(DeltaJ),0) TotalDeltaJ
		FROM [bag].[CONOPS_BAG_DELTA_J_V] 
		WHERE shiftflag = @SHIFT;
		
		SELECT 
			TimeinHour,
			ShovelId,
			DeltaJ
		FROM [bag].[CONOPS_BAG_DELTA_J_V] 
		WHERE DeltaJ IS NOT NULL
		AND shiftflag = @SHIFT;

		--DrillDown
		SELECT
			TimeinHour,
			ROUND(SUM(TotalMaterialMined/1000.0),1) AS Tons,
			ISNULL(ROUND(SUM(shovelshifttarget/1000.0),1),0) TonsTarget,
			ROUND(AVG(UofA),0) AS UseOfAvailability,
			UseOfAvailabilityTarget,
			ROUND(AVG(EFH),0) AS EquivalentFlatHaul,
			EFHTarget AS EquivalentFlatHaulTarget
		FROM [bag].[CONOPS_BAG_DELTA_J_V] a
		INNER JOIN [bag].[CONOPS_BAG_HOURLY_TRUCK_ASSET_EFFICIENCY_V] b
		ON a.shiftflag = b.shiftflag AND a.shovelid = b.Equipment AND a.TimeinHour = b.Hr
		CROSS JOIN (
		SELECT TOP 1
			TRUCKUSEOFAVAILABILITY as useOfAvailabilityTarget
		FROM [bag].[plan_values_prod_sum] WITH (NOLOCK)
		ORDER BY EffectiveDate DESC) c
		WHERE b.eqmtunit = 2
		AND a.shiftflag = @SHIFT
		GROUP BY TimeinHour,UseOfAvailabilityTarget,EFHTarget;
		
	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
			ROUND(AVG(DeltaJ),0) TotalDeltaJ
		FROM [cer].[CONOPS_CER_DELTA_J_V] 
		WHERE shiftflag = @SHIFT;
		
		SELECT 
			TimeinHour,
			ShovelId,
			DeltaJ
		FROM [cer].[CONOPS_CER_DELTA_J_V] 
		WHERE DeltaJ IS NOT NULL
		AND shiftflag = @SHIFT;

		--DrillDown
		SELECT
			TimeinHour,
			ROUND(SUM(TotalMaterialMined/1000.0),1) AS Tons,
			ISNULL(ROUND(SUM(shovelshifttarget/1000.0),1),0) TonsTarget,
			ROUND(AVG(UofA),0) AS UseOfAvailability,
			useOfAvailabilityTarget,
			ROUND(AVG(EFH),0) AS EquivalentFlatHaul,
			EFHTarget AS EquivalentFlatHaulTarget
		FROM [cer].[CONOPS_CER_DELTA_J_V] a
		INNER JOIN [cer].[CONOPS_CER_HOURLY_TRUCK_ASSET_EFFICIENCY_V] b
		ON a.shiftflag = b.shiftflag AND a.shovelid = b.Equipment AND a.TimeinHour = b.Hr
		CROSS JOIN (
		SELECT TOP 1
			useOfAvailabilityTarget
		FROM [cer].[CONOPS_CER_DELTA_C_TARGET_V]
		ORDER BY shiftid DESC) c
		WHERE b.eqmtunit = 2
		AND a.shiftflag = @SHIFT
		GROUP BY TimeinHour,useOfAvailabilityTarget,EFHTarget;

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT 
			ROUND(AVG(DeltaJ),0) TotalDeltaJ
		FROM [chi].[CONOPS_CHI_DELTA_J_V] 
		WHERE shiftflag = @SHIFT;
		
		SELECT 
			TimeinHour,
			ShovelId,
			DeltaJ
		FROM [chi].[CONOPS_CHI_DELTA_J_V] 
		WHERE DeltaJ IS NOT NULL
		AND shiftflag = @SHIFT;

		--DrillDown
			SELECT
			TimeinHour,
			ROUND(SUM(TotalMaterialMined/1000.0),1) AS Tons,
			ISNULL(ROUND(SUM(shovelshifttarget/1000.0),1),0) TonsTarget,
			ROUND(AVG(UofA),0) AS UseOfAvailability,
			useOfAvailabilityTarget,
			ROUND(AVG(EFH),0) AS EquivalentFlatHaul,
			EFHTarget AS EquivalentFlatHaulTarget
		FROM [chi].[CONOPS_CHI_DELTA_J_V] a
		INNER JOIN [chi].[CONOPS_CHI_HOURLY_TRUCK_ASSET_EFFICIENCY_V] b
		ON a.shiftflag = b.shiftflag AND a.shovelid = b.Equipment AND a.TimeinHour = b.Hr
		CROSS JOIN (
		SELECT TOP 1
			useOfAvailabilityTarget
		FROM [chi].[CONOPS_CHI_DELTA_C_TARGET_V]
		ORDER BY dateeffective DESC) c
		WHERE b.eqmtunit = 2
		AND a.shiftflag = @SHIFT
		GROUP BY TimeinHour,useOfAvailabilityTarget,EFHTarget;

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT 
			ROUND(AVG(