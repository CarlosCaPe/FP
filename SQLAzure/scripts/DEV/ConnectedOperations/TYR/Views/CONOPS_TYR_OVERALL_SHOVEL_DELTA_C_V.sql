CREATE VIEW [TYR].[CONOPS_TYR_OVERALL_SHOVEL_DELTA_C_V] AS

--select * from [tyr].[CONOPS_TYR_OVERALL_SHOVEL_DELTA_C_V]
CREATE VIEW [TYR].[CONOPS_TYR_OVERALL_SHOVEL_DELTA_C_V]
AS 

WITH STAT AS (
SELECT shiftid
	,eqmt
	,eqmttype
	,reasonidx
	,reasons
	,[status] AS eqmtcurrstatus
	,ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
FROM [TYR].[asset_efficiency](NOLOCK)
WHERE unittype = 'Shovel'
)

SELECT a.shiftflag
	,a.siteflag
	,b.excav
	,d.eqmttype
	,AVG(Delta_c) AS DeltaC
	,DeltaCtarget AS ShiftTarget
	,eqmtcurrstatus
FROM [TYR].[CONOPS_TYR_SHIFT_INFO_V] a
LEFT JOIN [DBO].delta_c b WITH (NOLOCK)
	ON a.shiftindex = b.shiftindex
	AND b.site_code = 'TYR'
LEFT JOIN STAT d ON a.shiftid = d.shiftid
	AND b.EXCAV = d.eqmt
	AND d.num = 1
LEFT JOIN [TYR].[CONOPS_TYR_DELTA_C_TARGET_V] e
	ON a.shiftid = e.shiftid
GROUP BY a.shiftflag
	,a.siteflag
	,DeltaCtarget
	,b.excav
	,d.eqmttype
	,eqmtcurrstatus

