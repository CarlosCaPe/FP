CREATE VIEW [CHI].[CONOPS_CHI_DELTA_C_TARGET_V] AS









--select * from [chi].[CONOPS_CHI_DELTA_C_TARGET_V] WITH (NOLOCK)
CREATE VIEW [chi].[CONOPS_CHI_DELTA_C_TARGET_V] 
AS

SELECT TOP 1 Right([Year], 2) + FORMAT(CAST([Month] AS numeric), '00') [ShiftId],
	   DATEEFFECTIVE,
	   siteflag,
       Delta_c_target,
       EFHtarget,
       spottarget,
       loadtarget,
       dumpingtarget,
       dumpingAtCrusherTarget,
       dumpingatStockpileTarget,
	   idletimetarget,
	   emptytraveltarget,
	   loadedtraveltarget,
	   ShovelAssetEfficiencyTarget,
       useOfAvailabilityTarget
FROM (
	SELECT DATEEFFECTIVE,
		   REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 1)) AS [Year],
		   REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 2)) AS [Month],
		   siteflag,
		   [DeltaC] AS Delta_c_target,
		   [EFH] AS EFHtarget,
		   CAST([PlannedSpotTimeMin] AS numeric)  AS spottarget,
		   CAST([PlannedLoadTimePH2800MIN] AS numeric) AS loadtarget,
		   CAST([PlannedDumpTimeMin] AS numeric)  AS dumpingtarget,
		   CAST([PlannedDumpTimeMin] AS numeric) AS dumpingAtCrusherTarget,
		   CAST([PlannedDumpTimeMin] AS numeric) AS dumpingatStockpileTarget,
		   0 AS idletimetarget,
		   [PlannedEmptyTravelTimeMin] AS emptytraveltarget,
		   [PlannedLoadedTravelTimeMin] AS loadedtraveltarget,
		   COALESCE(CAST([ElectricShovelAssetEfficiency] AS decimal(10,2)), 0) AS ShovelAssetEfficiencyTarget,
		   (COALESCE(CAST([TruckAvailability] AS decimal(10,2)), 0) * COALESCE(CAST([TruckAssetEfficiency] AS decimal(10,2)), 0) ) / 100 AS useOfAvailabilityTarget
	FROM [chi].[PLAN_VALUES] (nolock)
) [a]

WHERE GETDATE() >= DateEffective 
ORDER BY DateEffective DESC




