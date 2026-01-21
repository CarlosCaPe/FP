CREATE VIEW [SIE].[CONOPS_SIE_PAYLOAD_MEASURETON_V] AS





--select * from [SIE].[CONOPS_SIE_PAYLOAD_MEASURETON_V] where shiftflag = 'curr'
CREATE VIEW [SIE].[CONOPS_SIE_PAYLOAD_MEASURETON_V]
AS

SELECT
	s.SITEFLAG,
	s.SHIFTID,
	TRUCK,
	EXCAV,
	MEASURETON,
	PayloadTarget
FROM [dbo].[lh_load] [load] WITH (NOLOCK)
LEFT JOIN [SIE].[CONOPS_SIE_SHIFT_INFO_V] [s]
	ON [load].SHIFTINDEX = [s].SHIFTINDEX
LEFT JOIN dbo.PAYLOAD_TARGET t WITH(NOLOCK)
	ON s.siteflag = t.siteflag
WHERE [load].MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'SIE')
	AND SITE_CODE = 'SIE'
	AND s.shiftid IS NOT NULL



