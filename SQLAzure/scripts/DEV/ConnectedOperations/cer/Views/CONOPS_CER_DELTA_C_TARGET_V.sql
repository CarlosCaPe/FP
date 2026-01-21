CREATE VIEW [cer].[CONOPS_CER_DELTA_C_TARGET_V] AS



--select * from [cer].[CONOPS_CER_DELTA_C_TARGET_V] WITH (NOLOCK)
CREATE VIEW [cer].[CONOPS_CER_DELTA_C_TARGET_V]
AS

SELECT ShiftId,
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
	   ShiftChangeTarget,
	   ShovelAssetEfficiencyTarget,
       useOfAvailabilityTarget
FROM (
	SELECT TOP 2 ShiftId,
		[pv].siteflag,
		[pv].[TOTALCYCLEDELTA] AS Delta_c_target,
		[pv].[EQUIVFLATHAULHAULPROF] AS EFHtarget,
		[pv].[LOADINGTIMETIMES] AS loadtarget,
		[pv].[SPOTTINGTIMETIMES] AS spottarget,
		[pv].[DUMPINGTIMETIMES] AS dumpingtarget,
		[pv].[DUMPINGATCRUSHERTIMES] AS dumpingAtCrusherTarget,
		[pv].[DUMPINGATSTOCKPILETIMES] AS dumpingatStockpileTarget,
		[pv].[IDLEATEXCAVATORTIMES] AS idletimetarget,
		[pv].[EMPTYTRAVELTIMETIMES] AS emptytraveltarget,
		[pv].[LOADEDTRAVELTIMETIMES] AS loadedtraveltarget,
		[pv].[SHIFTCHANGEMIN] AS ShiftChangeTarget,
		CAST(REPLACE([pv].[ASSETEFFICIENCYTOTALLOADING], '%', '') AS DECIMAL(2,2)) AS ShovelAssetEfficiencyTarget,
		(CAST(REPLACE([pv].[AVAILABILITYTOTALTRUCK], '%', '') AS DECIMAL(2,2)) * CAST(REPLACE([pv].[ASSETEFFICIENCYTOTALTRUCK], '%', '') AS DECIMAL(2,2))) AS useOfAvailabilityTarget
	FROM [cer].[SHIFT_INFO] [si]
	LEFT JOIN [cer].[PLAN_VALUES] [pv] (nolock)
	ON SUBSTRING([pv].TITLE, 1, 3) + '-' + RIGHT([pv].TITLE, 2) = CAST(FORMAT(CAST(SUBSTRING(CAST(ShiftId AS varchar(max)), 1, 6) AS DATE), 'MMM') AS VARCHAR(3)) + '-' + CAST( SUBSTRING(CAST(ShiftId AS varchar(max)), 1, 2) AS VARCHAR(2))
	ORDER BY ShiftStartTimestamp DESC
) [a]

