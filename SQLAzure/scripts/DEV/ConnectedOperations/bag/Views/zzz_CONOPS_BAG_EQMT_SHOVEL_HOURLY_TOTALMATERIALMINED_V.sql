CREATE VIEW [bag].[zzz_CONOPS_BAG_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_V] AS


--select * from [bag].[CONOPS_BAG_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_V]
CREATE VIEW [bag].[zzz_CONOPS_BAG_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_V]
AS

WITH CTE AS (
SELECT
shiftid,
shovelid,
shiftdumptime,
TotalMaterialMoved,
TotalMaterialMined
FROM [bag].[CONOPS_BAG_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_DUMPTIME_V])

SELECT 
shiftflag,
siteflag,
shovelid,
SUM(TotalMaterialMoved) AS TotalMaterialMoved,
SUM(TotalMaterialMined) AS TotalMaterialMined,
CONCAT(LEFT(SHIFTSTARTDATETIME,10),' ',RIGHT('00'+ CAST((DATEPART(HOUR, shiftdumptime)) AS VARCHAR(2)) ,2),':00:00.000') AS TimeinHour
FROM BAG.CONOPS_BAG_SHIFT_INFO_V a
LEFT JOIN CTE b ON a.shiftid = b.shiftid
WHERE b.shiftdumptime IS NOT NULL
GROUP BY DATEPART(HOUR, shiftdumptime),shovelid,shiftflag,siteflag,SHIFTSTARTDATETIME




