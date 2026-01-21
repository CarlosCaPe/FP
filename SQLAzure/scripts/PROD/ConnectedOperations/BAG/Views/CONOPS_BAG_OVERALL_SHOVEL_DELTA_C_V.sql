CREATE VIEW [BAG].[CONOPS_BAG_OVERALL_SHOVEL_DELTA_C_V] AS


--select * from [bag].[CONOPS_BAG_OVERALL_SHOVEL_DELTA_C_V]   
CREATE VIEW [bag].[CONOPS_BAG_OVERALL_SHOVEL_DELTA_C_V]   
AS

WITH CTE AS (
	SELECT s.SHIFTINDEX
		,SHOVEL_NAME AS excav
		,COUNT(*) AS NrOfLoad
		,SUM(REPORT_PAYLOAD_SHORT_TONS) AS Tons
	FROM bag.FLEET_TRUCK_CYCLE_V e WITH (NOLOCK)
	RIGHT JOIN BAG.CONOPS_BAG_SHIFT_INFO_V s WITH (NOLOCK) ON e.SHIFT_ID = s.SHIFTID
	GROUP BY s.SHIFTINDEX
		,SHOVEL_NAME
),

ShovelTons AS(
	SELECT shiftindex
		,excav
		,SUM(NrofLoad) NrofLoad
		,SUM(Tons) Tons
	FROM CTE
	GROUP BY shiftindex
		,excav
),

STAT AS (
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
	,SUM(Delta_c * Tons) / SUM(Tons) AS DeltaC
	,ShiftTarget
	,eqmtcurrstatus
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a
LEFT JOIN [DBO].delta_c b WITH (NOLOCK) ON a.shiftindex = b.shiftindex
	AND b.site_code = 'BAG'
LEFT JOIN ShovelTons c ON a.shiftindex = c.shiftindex
	AND b.excav = c.excav
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

