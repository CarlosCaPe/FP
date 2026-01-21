CREATE VIEW [cer].[CONOPS_CER_EOS_EQMT_BREAK_V] AS


--SELECT * FROM [cer].[CONOPS_CER_EOS_EQMT_BREAK_V] WHERE shiftflag = 'curr' order by datetime
CREATE VIEW [cer].[CONOPS_CER_EOS_EQMT_BREAK_V]
AS

WITH CTE AS (
SELECT
shiftid,
eqmt,
UnitType,
Duration,
reasonidx
FROM [cer].[asset_efficiency] WITH (NOLOCK)
WHERE reasonidx IN (401,321,414))


SELECT
siteflag,
shiftflag,
eqmt,
UnitType,
Duration,
reasonidx AS Reason
FROM [cer].[CONOPS_CER_SHIFT_INFO_V] a
LEFT JOIN CTE b on a.shiftid = b.shiftid


