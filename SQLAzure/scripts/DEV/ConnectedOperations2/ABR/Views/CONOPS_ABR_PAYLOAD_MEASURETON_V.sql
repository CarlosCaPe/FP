CREATE VIEW [ABR].[CONOPS_ABR_PAYLOAD_MEASURETON_V] AS





--select * from [ABR].[CONOPS_ABR_PAYLOAD_MEASURETON_V] where shiftflag = 'curr'
CREATE VIEW [ABR].[CONOPS_ABR_PAYLOAD_MEASURETON_V]
AS

SELECT
	s.SITEFLAG,
	s.SHIFTID,
	TRUCK,
	EXCAV,
	MEASURETON,
	PayloadTarget
FROM [dbo].[lh_load] [load] WITH (NOLOCK)
LEFT JOIN [ABR].[CONOPS_ABR_SHIFT_INFO_V] [s]
	ON [load].SHIFTINDEX = [s].SHIFTINDEX
LEFT JOIN dbo.PAYLOAD_TARGET t WITH(NOLOCK)
	ON s.siteflag = t.siteflag
WHERE [load].MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'ABR')
	AND SITE_CODE = 'ELA'
	AND s.shiftid IS NOT NULL



