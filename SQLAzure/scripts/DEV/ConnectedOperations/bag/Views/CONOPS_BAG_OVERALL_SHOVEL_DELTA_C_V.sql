CREATE VIEW [bag].[CONOPS_BAG_OVERALL_SHOVEL_DELTA_C_V] AS

--select * from [bag].[CONOPS_BAG_OVERALL_SHOVEL_DELTA_C_V]
CREATE VIEW [bag].[CONOPS_BAG_OVERALL_SHOVEL_DELTA_C_V]
AS

WITH STAT AS (
SELECT shiftid
	,eqmt
	,eqmttype
	,reasonidx
	,reasons
	,[status] AS eqmtcurrstatus
	,ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
FROM [BAG].[asset_efficiency](NOLOCK)
WHERE unittype = 'shovel'
)

SELECT a.shiftflag
	,a.siteflag
	,b.excav
	,d.eqmttype
	,AVG(Delta_c) AS DeltaC
	,ShiftTarget
	,eqmtcurrstatus
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a
LEFT JOIN [DBO].delta_c b WITH (NOLOCK)
	ON a.shiftindex = b.shiftindex
	AND b.site_code = 'BAG'
LEFT JOIN STAT d ON a.shiftid = d.shiftid
	AND b.EXCAV = d.eqmt
	AND d.num = 1
LEFT JOIN (
	SELECT substring(replace(EffectiveDate, '-', ''), 3, 4) AS shiftdate
		,TotalDeltaC AS ShiftTarget
	FROM [bag].[plan_values_prod_sum] WITH (NOLOCK)
	) e ON LEFT(a.shiftid, 4) = e.shiftdate
GROUP BY a.shiftflag
	,a.siteflag
	,ShiftTarget
	,b.excav
	,d.eqmttype
	,eqmtcurrstatus

