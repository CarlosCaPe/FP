CREATE VIEW [dbo].[CONOPS_LH_WORST_HAUL_ROUTE_V] AS


CREATE VIEW [dbo].[CONOPS_LH_WORST_HAUL_ROUTE_V]
AS

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
FROM (
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
	FROM [mor].[CONOPS_MOR_WORST_HAUL_ROUTE_V] WITH (NOLOCK)
) [main]
WHERE siteflag = 'MOR' AND
	  rn = 1

UNION ALL

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
FROM (
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
	FROM [bag].[CONOPS_BAG_WORST_HAUL_ROUTE_V] WITH (NOLOCK)
) [main]
WHERE siteflag = 'BAG' AND
	  rn = 1


