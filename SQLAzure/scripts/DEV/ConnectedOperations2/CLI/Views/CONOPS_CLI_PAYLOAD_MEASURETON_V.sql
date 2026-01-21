CREATE VIEW [CLI].[CONOPS_CLI_PAYLOAD_MEASURETON_V] AS





--select * from [CLI].[CONOPS_CLI_PAYLOAD_MEASURETON_V] where shiftflag = 'curr'
CREATE VIEW [CLI].[CONOPS_CLI_PAYLOAD_MEASURETON_V]
AS

SELECT
	s.SITEFLAG,
	s.SHIFTID,
	TRUCK,
	EXCAV,
	MEASURETON,
	PayloadTarget
FROM [dbo].[lh_load] [load] WITH (NOLOCK)
LEFT JOIN [CLI].[CONOPS_CLI_SHIFT_INFO_V] [s]
	ON [load].SHIFTINDEX = [s].SHIFTINDEX
LEFT JOIN dbo.PAYLOAD_TARGET t WITH(NOLOCK)
	ON s.siteflag = t.siteflag
WHERE [load].MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'CLI')
	AND SITE_CODE = 'CLI'
	AND s.shiftid IS NOT NULL



