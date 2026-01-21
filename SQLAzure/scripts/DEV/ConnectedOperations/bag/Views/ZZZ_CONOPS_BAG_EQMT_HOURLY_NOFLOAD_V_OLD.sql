CREATE VIEW [bag].[ZZZ_CONOPS_BAG_EQMT_HOURLY_NOFLOAD_V_OLD] AS







--SELECT * FROM [bag].[CONOPS_BAG_EQMT_HOURLY_NOFLOAD_V] WHERE shiftflag = 'prev'

CREATE VIEW [bag].[CONOPS_BAG_EQMT_HOURLY_NOFLOAD_V_OLD]
AS


WITH CTE AS (
SELECT
shiftindex,
site_code,
excav AS Equipment,
count(*) AS NofLoad,
timeload_ts AS LoadTime
FROM dbo.lh_load WITH (NOLOCK)
where site_code = 'BAG' 
GROUP BY shiftindex,excav,timeload_ts,site_code)

SELECT 
shiftflag,
siteflag,
Equipment,
SUM(NofLoad) AS NofLoad,
CONCAT(LEFT(SHIFTSTARTDATETIME,10),' ',RIGHT('00'+ CAST((DATEPART(HOUR, LoadTime)+1) AS VARCHAR(2)) ,2),':00:00.000') AS TimeinHour
FROM BAG.CONOPS_BAG_SHIFT_INFO_V a
LEFT JOIN CTE b ON a.shiftindex = b.SHIFTINDEX
GROUP BY DATEPART(HOUR, LoadTime),Equipment,shiftflag,siteflag,SHIFTSTARTDATETIME



