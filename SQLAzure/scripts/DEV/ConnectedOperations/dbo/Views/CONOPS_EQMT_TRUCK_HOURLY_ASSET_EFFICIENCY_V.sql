CREATE VIEW [dbo].[CONOPS_EQMT_TRUCK_HOURLY_ASSET_EFFICIENCY_V] AS



--select * from [dbo].[CONOPS_EQMT_TRUCK_HOURLY_ASSET_EFFICIENCY_V]
CREATE VIEW [dbo].[CONOPS_EQMT_TRUCK_HOURLY_ASSET_EFFICIENCY_V]
AS


SELECT
shiftflag,
siteflag,
Equipment,
Hr AS TimeinHour,
AE AS AssetEfficiency,
Avail AS Avalilability,
UofA AS UseOfAvailability 
FROM [bag].[CONOPS_BAG_HOURLY_TRUCK_ASSET_EFFICIENCY_V]
WHERE EqmtUnit = 1
AND siteflag = 'BAG'


UNION ALL

SELECT
shiftflag,
'CVE' siteflag,
Equipment,
Hr AS TimeinHour,
AE AS AssetEfficiency,
Avail AS Avalilability,
UofA AS UseOfAvailability 
FROM [cer].[CONOPS_CER_HOURLY_TRUCK_ASSET_EFFICIENCY_V]
WHERE EqmtUnit = 1
AND siteflag = 'CER'


UNION ALL

SELECT
shiftflag,
'CHN' siteflag,
Equipment,
Hr AS TimeinHour,
AE AS AssetEfficiency,
Avail AS Avalilability,
UofA AS UseOfAvailability 
FROM [chi].[CONOPS_CHI_HOURLY_TRUCK_ASSET_EFFICIENCY_V]
WHERE EqmtUnit = 1
AND siteflag = 'CHI'


UNION ALL

SELECT
shiftflag,
siteflag,
Equipment,
Hr AS TimeinHour,
AE AS AssetEfficiency,
Avail AS Avalilability,
UofA AS UseOfAvailability 
FROM [cli].[CONOPS_CLI_HOURLY_TRUCK_ASSET_EFFICIENCY_V]
WHERE EqmtUnit = 1
AND siteflag = 'CMX'


UNION ALL

SELECT
shiftflag,
siteflag,
Equipment,
Hr AS TimeinHour,
AE AS AssetEfficiency,
Avail AS Avalilability,
UofA AS UseOfAvailability 
FROM [mor].[CONOPS_MOR_HOURLY_TRUCK_ASSET_EFFICIENCY_V]
WHERE EqmtUnit = 1
AND siteflag = 'MOR'


UNION ALL

SELECT
shiftflag,
'SAM' siteflag,
Equipment,
Hr AS TimeinHour,
AE AS AssetEfficiency,
Avail AS Avalilability,
UofA AS UseOfAvailability 
FROM [saf].[CONOPS_SAF_HOURLY_TRUCK_ASSET_EFFICIENCY_V]
WHERE EqmtUnit = 1
AND siteflag = 'SAF'


UNION ALL

SELECT
shiftflag,
siteflag,
Equipment,
Hr AS TimeinHour,
AE AS AssetEfficiency,
Avail AS Avalilability,
UofA AS UseOfAvailability 
FROM [sie].[CONOPS_SIE_HOURLY_TRUCK_ASSET_EFFICIENCY_V]
WHERE EqmtUnit = 1
AND siteflag = 'SIE'



