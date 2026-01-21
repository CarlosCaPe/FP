CREATE VIEW [ABR].[CONOPS_ABR_OVERALL_SHOVEL_DELTA_C_V] AS

--select * from [abr].[CONOPS_ABR_OVERALL_SHOVEL_DELTA_C_V]
CREATE VIEW [ABR].[CONOPS_ABR_OVERALL_SHOVEL_DELTA_C_V]
AS 

WITH STAT AS (
SELECT shiftid
	,eqmt
	,eqmttype
	,reasonidx
	,reasons
	,[status] AS eqmtcurrstatus
	,ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
FROM [ABR].[asset_efficiency](NOLOCK)
WHERE unittype = 'Excav'
)

SELECT a.shiftflag
	,a.siteflag
	,b.excav
	,d.eqmttype
	,AVG(Delta_c) AS DeltaC
	,DeltaCtarget AS ShiftTarget
	,eqmtcurrstatus
FROM [ABR].[CONOPS_ABR_SHIFT_INFO_V] a
LEFT JOIN [DBO].delta_c b WITH (NOLOCK)
	ON a.shiftindex = b.shiftindex
	AND b.site_code = 'ELA'
LEFT JOIN STAT d ON a.shiftid = d.shiftid
	AND b.EXCAV = d.eqmt
	AND d.num = 1
LEFT JOIN [abr].[CONOPS_ABR_DELTA_C_TARGET_V] e
	ON a.shiftid = e.shiftid
GROUP BY a.shiftflag
	,a.siteflag
	,DeltaCtarget
	,b.excav
	,d.eqmttype
	,eqmtcurrstatus

