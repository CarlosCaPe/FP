CREATE VIEW [ABR].[CONOPS_ABR_EQMT_SHOVEL_V] AS




-- SELECT * FROM [abr].[CONOPS_ABR_EQMT_SHOVEL_V] where shiftflag = 'prev'
CREATE VIEW [ABR].[CONOPS_ABR_EQMT_SHOVEL_V]
AS

WITH Shovel AS (
SELECT
	shiftflag,
	siteflag,
	shiftindex,
	shiftid,
	shovelid,
	[location],
	statusname,
	reasonid,
	reasondesc,
	duration AS TimeInState,
	CrewName AS Crew,
	UPPER(operator) AS operator,
	operatorimageURL
FROM [abr].[CONOPS_ABR_SHOVEL_INFO_V]),

Details AS (
SELECT
	shiftflag,
	siteflag,
	shovelid,
	TotalMaterialMined,
	TotalMaterialMinedTarget,
	TotalMaterialMoved,
	TotalMaterialMovedTarget,
	payload,
	PayloadTarget,
	TonsPerReadyHour,
	TonsPerReadyHourTarget,
	NumberOfLoads,
	NumberOfLoadsTarget,
	Spotting,
	SpottingTarget,
	Loading,
	LoadingTarget,
	IdleTime,
	IdleTimeTarget
FROM [abr].[CONOPS_ABR_SHOVEL_POPUP_V]),

AE AS (
SELECT
	ae.shiftid,
	eqmt AS shovelid,
	Ops_efficient_pct AS AssetEfficiency,
	t.ShovelAssetEfficiencyTarget AS AssetEfficiencyTarget,
	availability_pct AS Availability,
	0 AvailabilityTarget,
	use_of_availability_pct AS UseOfAvailability,
	t.useOfAvailabilityTarget AS UseOfAvailabilityTarget
FROM [abr].[CONOPS_ABR_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] ae
LEFT JOIN [abr].[CONOPS_ABR_DELTA_C_TARGET_V] t
ON t.ShiftId = ae.shiftid
),

/*PC AS (
SELECT
	shiftindex,
	shovelid,
	UnderLoaded,
	BelowTarget,
	OnTarget,
	AboveTarget,
	OverLoaded,
	InvalidPayload
FROM [abr].[CONOPS_ABR_EQMT_PAYLOAD_CATEGORY_V]),

PCTarget AS (
SELECT
	ShiftIndex,
	shovelid,
	UnderLoadedTarget,
	BelowTargetTarget,
	OnTargetTarget,
	AboveTargetTarget,
	OverLoadedTarget,
	InvalidPayloadTarget
FROM [abr].[CONOPS_ABR_EQMT_PAYLOAD_CATEGORY_TARGET_V]),*/

HT AS (
SELECT 
	site_code,
	shiftindex,
	excav,
	ROUND(AVG(hangtime)/60.0,2) hangtime
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'ELA'
GROUP BY site_code, shiftindex, excav)


SELECT
	a.shiftflag,
	a.siteflag,
	a.shovelid,
	[location],
	statusname,
	reasonid,
	reasondesc,
	Crew,
	TimeInState,
	'Recent operator feedback was submitted, please check employee HR records for details' AS Comment,
	operator,
	operatorimageURL,
	TotalMaterialMined,
	TotalMaterialMinedTarget,
	TotalMaterialMoved,
	TotalMaterialMovedTarget,
	payload,
	PayloadTarget,
	TonsPerReadyHour,
	TonsPerReadyHourTarget,
	NumberOfLoads,
	NumberOfLoadsTarget,
	Spotting,
	SpottingTarget,
	Loading,
	LoadingTarget,
	IdleTime,
	IdleTimeTarget,
	Hangtime,
	NULL HangtimeTarget,
	ISNULL(AssetEfficiency,0) AssetEfficiency,
	ISNULL(AssetEfficiencyTarget,0) AssetEfficiencyTarget,
	ISNULL(Availability,0) Availability,
	ISNULL(AvailabilityTarget,0) AvailabilityTarget,
	ISNULL(UseOfAvailability,0) UseOfAvailability,
	ISNULL(UseOfAvailabilityTarget,0) UseOfAvailabilityTarget,
	--0 UnderLoaded,
	--0 UnderLoadedTarget,
	--0 BelowTarget,
	--0 BelowTargetTarget,
	--0 OnTarget,
	--0 OnTargetTarget,
	--0 AboveTarget,
	--0 AboveTargetTarget,
	--0 OverLoaded,
	--0 OverLoadedTarget,
	--0 InvalidPayload,
	--0 InvalidPayloadTarget,
	0 ToothMetrics
FROM Shovel a
LEFT JOIN Details b
	ON a.shiftflag = b.shiftflag 
	AND a.siteflag = b.siteflag 
	AND a.ShovelID = b.ShovelID
LEFT JOIN AE c
	ON a.shiftid = c.shiftid 
	AND a.ShovelID = c.ShovelID
/*LEFT JOIN PC d
	ON a.shiftindex = d.shiftindex
	AND a.ShovelID = d.ShovelId
LEFT JOIN PCTarget e
	ON a.shiftindex = e.shiftindex
	AND a.ShovelID = e.ShovelId*/
LEFT JOIN HT g
	ON a.shiftindex = g.SHIFTINDEX
	AND a.ShovelID = g.EXCAV





