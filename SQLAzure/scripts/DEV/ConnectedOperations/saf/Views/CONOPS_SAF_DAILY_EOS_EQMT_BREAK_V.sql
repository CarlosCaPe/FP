CREATE VIEW [saf].[CONOPS_SAF_DAILY_EOS_EQMT_BREAK_V] AS
  
  
  
  
--SELECT * FROM [saf].[CONOPS_SAF_DAILY_EOS_EQMT_BREAK_V] WHERE shiftflag = 'curr' order by datetime  
CREATE VIEW [saf].[CONOPS_SAF_DAILY_EOS_EQMT_BREAK_V]  
AS  
  
WITH CTE AS (  
SELECT  
shiftid,  
eqmt,  
UnitType,  
Duration,  
reasonidx  
FROM [saf].[asset_efficiency] WITH (NOLOCK)  
WHERE reasonidx IN (400,414))  
  
  
SELECT  
siteflag,  
shiftflag,  
eqmt,  
UnitType,  
Duration,  
reasonidx AS Reason  
FROM [saf].[CONOPS_SAF_EOS_SHIFT_INFO_V] a  
LEFT JOIN CTE b on a.shiftid = b.shiftid  
  
  
  
