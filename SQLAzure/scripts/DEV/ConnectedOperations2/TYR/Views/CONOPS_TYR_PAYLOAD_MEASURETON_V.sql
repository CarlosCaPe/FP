CREATE VIEW [TYR].[CONOPS_TYR_PAYLOAD_MEASURETON_V] AS





--select * from [TYR].[CONOPS_TYR_PAYLOAD_MEASURETON_V] where shiftflag = 'curr'
CREATE VIEW [TYR].[CONOPS_TYR_PAYLOAD_MEASURETON_V]
AS

SELECT
	s.SITEFLAG,
	s.SHIFTID,
	TRUCK,
	EXCAV,
	MEASURETON,
	PayloadTarget
FROM [dbo].[lh_load] [load] WITH (NOLOCK)
LEFT JOIN [TYR].[CONOPS_TYR_SHIFT_INFO_V] [s]
	ON [load].SHIFTINDEX = [s].SHIFTINDEX
LEFT JOIN dbo.PAYLOAD_TARGET t WITH(NOLOCK)
	ON s.siteflag = t.siteflag
WHERE [load].MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'TYR')
	AND SITE_CODE = 'TYR'
	AND s.shiftid IS NOT NULL



