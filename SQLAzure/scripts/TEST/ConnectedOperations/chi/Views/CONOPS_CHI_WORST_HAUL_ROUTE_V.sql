CREATE VIEW [chi].[CONOPS_CHI_WORST_HAUL_ROUTE_V] AS



-- SELECT * FROM [chi].[CONOPS_CHI_WORST_HAUL_ROUTE_V] WITH (NOLOCK)
CREATE VIEW [chi].[CONOPS_CHI_WORST_HAUL_ROUTE_V] 
AS

WITH cte AS (
	SELECT val.SHIFTINDEX,
		   val.Site_code,
		   val.TRUCK,
		   val.SHOVEL,
		   val.DUMPNAME,
		   val.NUMLOADS,
		   CAST(val.SUM_LT_DELTA AS DECIMAL(5,0)) AS TOTAL_MIN_OVER_EXPECTED,
		   rn
	FROM (
		SELECT delta.SHIFTINDEX AS SHIFTINDEX,
			   Site_code,
				delta.DUMPNAME AS DUMPNAME,
				delta.TRUCK,
				delta.EXCAV AS SHOVEL,
				SUM(CASE WHEN delta.VTODeltac3 IS NULL THEN 0 ELSE 1 END) AS NUMLOADS,
				SUM(delta.LT_DELTA) AS SUM_LT_DELTA,
				SUM(delta.CALCTRAVLOADED) AS SUM_TRAVEL_LOADED,
				ROW_NUMBER() OVER(PARTITION BY SHIFTINDEX, Site_code, delta.EXCAV ORDER BY SUM(delta.LT_DELTA) desc) rn
		FROM [dbo].[delta_c] AS delta WITH (NOLOCK)
		WHERE SITE_CODE = 'CHI'
		GROUP BY delta.SHIFTINDEX,
				delta.DUMPNAME,
				delta.TRUCK,
				delta.EXCAV,
				Site_code
	) val
),

WorstHaul AS(
SELECT shiftflag,
	   [siteflag],
	   TRUCK,
	   [Operator],
	   OperatorImageURL,
	   Shovel,
	   DUMPNAME,
	   TOTAL_MIN_OVER_EXPECTED,
	   [Status],
	   ReasonId,
	   ReasonDesc,
	   Location
FROM (
	SELECT cte.SHIFTINDEX,
	       shiftflag,
		   siteflag,
		   cte.site_code,
		   cte.TRUCK,
		   UPPER([truck].Operator) [Operator],
		   OperatorImageURL,
		   cte.Shovel,
		   cte.DUMPNAME,
		   cte.TOTAL_MIN_OVER_EXPECTED,
		   UPPER([truck].StatusName) [Status],
		   [truck].ReasonId,
		   [truck].ReasonDesc,
		   [truck].Location
	FROM cte
	LEFT JOIN [CHI].[CONOPS_CHI_TRUCK_DETAIL_V] [truck] WITH (NOLOCK)
	ON cte.TRUCK = [truck].TruckID
	   AND cte.SHIFTINDEX = [truck].shiftindex AND cte.site_code = [truck].[siteflag]
	WHERE cte.rn = 1
) [worstHaul]
WHERE shiftflag is not null),

WorstHaulRoute AS (
SELECT shiftflag,
		   siteflag,
		   TRUCK,
		   Operator,
		   OperatorImageURL,
		   [Status],
		   ReasonId,
		   ReasonDesc,
		   SHOVEL,
		   DUMPNAME,
		   Location,
		   TOTAL_MIN_OVER_EXPECTED,
		   ROW_NUMBER () OVER (PARTITION BY shiftflag, TRUCK ORDER BY TOTAL_MIN_OVER_EXPECTED desc) rn
	FROM WorstHaul WITH (NOLOCK)
	)

select shiftflag,
	   siteflag,
	   TRUCK,
	   Operator,
	   OperatorImageURL,
	   [Status],
	   ReasonId,
	   ReasonDesc,
	   SHOVEL,
	   DUMPNAME,
	   Location,
	   TOTAL_MIN_OVER_EXPECTED
FROM WorstHaulRoute
WHERE rn = 1

