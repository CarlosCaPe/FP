CREATE VIEW [cli].[CONOPS_CLI_OVERALL_SHOVEL_DELTA_C_V] AS

--select * from [cli].[CONOPS_CLI_OVERALL_SHOVEL_DELTA_C_V]
CREATE VIEW [cli].[CONOPS_CLI_OVERALL_SHOVEL_DELTA_C_V]
AS

WITH STAT AS (
SELECT shiftid
	,eqmt
	,eqmttype
	,reasonidx
	,reasons
	,[status] AS eqmtcurrstatus
	,ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
FROM [CLI].[asset_efficiency](NOLOCK)
WHERE unittype = 'Shovel'
)

SELECT a.shiftflag
	,a.siteflag
	,b.excav
	,d.eqmttype
	,AVG(Delta_c) AS DeltaC
	,8.6 AS ShiftTarget
	,eqmtcurrstatus
FROM [CLI].[CONOPS_CLI_SHIFT_INFO_V] a
LEFT JOIN [DBO].delta_c b WITH (NOLOCK)
	ON a.shiftindex = b.shiftindex
	AND b.site_code = 'CLI'
LEFT JOIN STAT d ON a.shiftid = d.shiftid
	AND b.EXCAV = d.eqmt
	AND d.num = 1
GROUP BY a.shiftflag
	,a.siteflag
	,b.excav
	,d.eqmttype
	,eqmtcurrstatus

