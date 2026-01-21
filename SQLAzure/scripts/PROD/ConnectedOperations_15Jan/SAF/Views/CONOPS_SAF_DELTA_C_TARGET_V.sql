CREATE VIEW [SAF].[CONOPS_SAF_DELTA_C_TARGET_V] AS






--select * from [saf].[CONOPS_SAF_DELTA_C_TARGET_V] WITH (NOLOCK)
CREATE VIEW [saf].[CONOPS_SAF_DELTA_C_TARGET_V] 
AS

SELECT CAST(Right([Year], 2) + FORMAT(CAST([Month] AS numeric), '00') +
		FORMAT(CAST([Day] AS numeric), '00') + FORMAT(CAST(SHIFT_CODE AS numeric), '000') AS numeric) [ShiftId],
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
		   REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 3)) AS [Day],
		   Shiftindex AS [SHIFT_CODE],
		   siteflag,
		   [DELTAC] AS Delta_c_target,
		   [EQUIVALENTFLATHAUL] AS EFHtarget,
		   [SPOTING] AS spottarget,
		   [LOADING] AS loadtarget,
		   2.5 AS dumpingtarget,
		   DUMPINGATCRUSHER AS dumpingAtCrusherTarget,
		   DUMPINGATCRUSHER AS dumpingatStockpileTarget,
		   1.44 AS idletimetarget,
		   [EMPTYTRAVEL] AS emptytraveltarget,
		   [LOADEDTRAVEL] AS loadedtraveltarget,
		   CAST(REPLACE(loadingassetefficiency, '%', '') AS numeric) AS ShovelAssetEfficiencyTarget,
		   (CAST(REPLACE([TRUCKAVAILIBILITY], '%', '') AS numeric) * CAST(REPLACE([TRUCKASSETEFFICIENCY], '%', '') AS numeric)) / 100 AS useOfAvailabilityTarget
	FROM [saf].[PLAN_VALUES] (nolock)
) [a]


