CREATE VIEW [CER].[CONOPS_CER_EQMT_SHOVEL_V] AS

  
  
-- SELECT * FROM [cer].[CONOPS_CER_EQMT_SHOVEL_V] where shiftflag = 'CURR'  
CREATE VIEW [cer].[CONOPS_CER_EQMT_SHOVEL_V]  
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
FROM [cer].[CONOPS_CER_SHOVEL_INFO_V]),  
  
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
 --Loading,  
 --LoadingTarget,  
 IdleTime,  
 IdleTimeTarget  
FROM [cer].[CONOPS_CER_SHOVEL_POPUP] WITH (NOLOCK)),  
  
ShovelLoad AS (  
SELECT  
 Shiftindex,  
 excav,  
 avg(Loading) Loading,  
 avg(LoadingTarget) LoadingTarget  
FROM [cer].[CONOPS_CER_EQMT_TRUCK_LOAD_DELTAC_V]  
GROUP BY shiftindex,excav),  
  
AE AS (  
SELECT  
 shiftid,  
 eqmt AS shovelid,  
 Ops_efficient_pct AS AssetEfficiency,  
 ShovelEfficiencyTarget AS AssetEfficiencyTarget,  
 availability_pct AS Availability,  
 ShovelAvailabilityTarget AS AvailabilityTarget,  
 use_of_availability_pct AS UseOfAvailability,  
 ShovelUtilizationTarget AS UseOfAvailabilityTarget  
FROM [CER].[CONOPS_CER_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] ae  
CROSS JOIN [CER].[CONOPS_CER_EQMT_ASSET_EFFICIENCY_TARGET_V] t),  
  
--PC AS (  
--SELECT  
-- shiftindex,  
-- shovelid,  
-- UnderLoaded,  
-- BelowTarget,  
-- OnTarget,  
-- AboveTarget,  
-- OverLoaded,  
-- InvalidPayload  
--FROM [cer].[CONOPS_CER_EQMT_PAYLOAD_CATEGORY_V]),  
  
--PCTarget AS (  
--SELECT  
-- ShiftIndex,  
-- shovelid,  
-- UnderLoadedTarget,  
-- BelowTargetTarget,  
-- OnTargetTarget,  
-- AboveTargetTarget,  
-- OverLoadedTarget,  
-- InvalidPayloadTarget  
--FROM [cer].[CONOPS_CER_EQMT_PAYLOAD_CATEGORY_TARGET_V]),  
  
HT AS (  
SELECT   
 site_code,  
 shiftindex,  
 excav,  
 ROUND(AVG(hangtime)/60.0,2) hangtime  
 FROM dbo.delta_c WITH (NOLOCK)  
 WHERE site_code = 'CER'  
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
 --ISNULL(UnderLoaded,0) UnderLoaded,  
 --ISNULL(UnderLoadedTarget,0) UnderLoadedTarget,  
 --ISNULL(BelowTarget,0) BelowTarget,  
 --ISNULL(BelowTargetTarget,0) AS BelowTargetTarget,  
 --ISNULL(OnTarget,0) OnTarget,  
 --ISNULL(OnTargetTarget,0) OnTargetTarget,  
 --ISNULL(AboveTarget,0) AboveTarget,  
 --ISNULL(AboveTargetTarget,0) AboveTargetTarget,  
 --ISNULL(OverLoaded,0) OverLoaded,  
 --ISNULL(OverLoadedTarget,0) OverLoadedTarget,  
 --ISNULL(InvalidPayload,0) InvalidPayload,  
 --ISNULL(InvalidPayloadTarget,0) InvalidPayloadTarget,  
 0 ToothMetrics  
FROM Shovel a  
LEFT JOIN Details b  
 ON a.shiftflag = b.shiftflag   
 AND a.siteflag = b.site