CREATE VIEW [SIE].[CONOPS_SIE_EQMT_HOURLY_PAYLOAD_V] AS





--SELECT * FROM [sie].[CONOPS_SIE_EQMT_HOURLY_PAYLOAD_V] WHERE shiftflag = 'prev' and equipment = 'S43'

CREATE VIEW [sie].[CONOPS_SIE_EQMT_HOURLY_PAYLOAD_V]
AS

WITH CTE AS (
SELECT
shiftindex,
site_code,
excav AS Equipment,
avg(measureton) as payload,
timeload_ts AS LoadTime
FROM dbo.lh_load WITH (NOLOCK)
where site_code = 'SIE' 
AND measureton >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'SIE')
GROUP BY shiftindex,excav,timeload_ts,site_code)

SELECT 
shiftflag,
siteflag,
Equipment,
avg(payload) as payload,
CONCAT(LEFT(SHIFTSTARTDATETIME,10),' ',RIGHT('00'+ CAST((DATEPART(HOUR, LoadTime)+1) AS VARCHAR(2)) ,2),':15:00.000') AS TimeinHour
FROM SIE.CONOPS_SIE_SHIFT_INFO_V a
LEFT JOIN CTE b ON a.shiftindex = b.SHIFTINDEX
GROUP BY DATEPART(HOUR, LoadTime),Equipment,shiftflag,siteflag,SHIFTSTARTDATETIME




