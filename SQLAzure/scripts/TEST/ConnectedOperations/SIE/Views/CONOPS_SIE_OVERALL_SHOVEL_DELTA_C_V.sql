CREATE VIEW [SIE].[CONOPS_SIE_OVERALL_SHOVEL_DELTA_C_V] AS

--select * from [sie].[CONOPS_SIE_OVERALL_SHOVEL_DELTA_C_V]
CREATE VIEW [sie].[CONOPS_SIE_OVERALL_SHOVEL_DELTA_C_V]
AS

WITH STAT AS (
SELECT shiftid
	,eqmt
	,eqmttype
	,reasonidx
	,reasons
	,[status] AS eqmtcurrstatus
	,ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
FROM [SIE].[asset_efficiency](NOLOCK)
WHERE unittype = 'Shovel'
)

SELECT a.shiftflag
	,a.siteflag
	,b.excav
	,d.eqmttype
	,AVG(Delta_c) AS DeltaC
	,ShiftTarget
	,eqmtcurrstatus
FROM [SIE].[CONOPS_SIE_SHIFT_INFO_V] a
LEFT JOIN [DBO].delta_c b WITH (NOLOCK)
	ON a.shiftindex = b.shiftindex
	AND b.site_code = 'SIE'
LEFT JOIN STAT d ON a.shiftid = d.shiftid
	AND b.EXCAV = d.eqmt
	AND d.num = 1
CROSS JOIN (
	SELECT TOP 1
		DeltaC as Shifttarget
	FROM [sie].[plan_values_prod_sum] (nolock)
	) e
GROUP BY a.shiftflag
	,a.siteflag
	,ShiftTarget
	,b.excav
	,d.eqmttype
	,eqmtcurrstatus

