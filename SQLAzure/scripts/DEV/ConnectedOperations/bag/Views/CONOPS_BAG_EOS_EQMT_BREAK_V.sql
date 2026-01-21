CREATE VIEW [bag].[CONOPS_BAG_EOS_EQMT_BREAK_V] AS




--SELECT * FROM [bag].[CONOPS_BAG_EOS_EQMT_BREAK_V] WHERE shiftflag = 'curr' order by datetime
CREATE VIEW [bag].[CONOPS_BAG_EOS_EQMT_BREAK_V]
AS

WITH CTE AS (
SELECT
shiftid,
eqmt,
UnitType,
Duration,
reasonidx
FROM [bag].[fleet_asset_efficiency_v] WITH (NOLOCK)
WHERE reasonidx IN (400,414))


SELECT
siteflag,
shiftflag,
eqmt,
UnitType,
Duration,
reasonidx AS Reason
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a
LEFT JOIN CTE b on a.shiftid = b.shiftid



