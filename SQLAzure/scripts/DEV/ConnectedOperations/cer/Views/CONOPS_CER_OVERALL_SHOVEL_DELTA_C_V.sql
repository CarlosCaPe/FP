CREATE VIEW [cer].[CONOPS_CER_OVERALL_SHOVEL_DELTA_C_V] AS

--select * from [cer].[CONOPS_CER_OVERALL_SHOVEL_DELTA_C_V]
CREATE VIEW [cer].[CONOPS_CER_OVERALL_SHOVEL_DELTA_C_V]
AS

WITH STAT AS (
SELECT shiftid
	,eqmt
	,eqmttype
	,reasonidx
	,reasons
	,[status] AS eqmtcurrstatus
	,ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
FROM [CER].[asset_efficiency](NOLOCK)
WHERE unittype = 'Pala'
)

SELECT a.shiftflag
	,a.siteflag
	,b.excav
	,d.eqmttype
	,AVG(Delta_c) AS DeltaC
	,ShiftTarget
	,eqmtcurrstatus
FROM [CER].[CONOPS_CER_SHIFT_INFO_V] a
LEFT JOIN [DBO].delta_c b WITH (NOLOCK)
	ON a.shiftindex = b.shiftindex
	AND b.site_code = 'CER'
LEFT JOIN STAT d ON a.shiftid = d.shiftid
	AND b.EXCAV = d.eqmt
	AND d.num = 1
CROSS JOIN (
	SELECT TOP 1
		Delta_c_target AS ShiftTarget
	FROM [cer].[CONOPS_CER_DELTA_C_TARGET_V] (nolock)
	) e
GROUP BY a.shiftflag
	,a.siteflag
	,ShiftTarget
	,b.excav
	,d.eqmttype
	,eqmtcurrstatus

