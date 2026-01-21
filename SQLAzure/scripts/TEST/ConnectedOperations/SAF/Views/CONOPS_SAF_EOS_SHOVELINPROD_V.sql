CREATE VIEW [SAF].[CONOPS_SAF_EOS_SHOVELINPROD_V] AS
  
  
  
--select * from [dbo].[CONOPS_SAF_EOS_SHOVELINPROD_V] where shiftflag = 'prev'  
CREATE VIEW [saf].[CONOPS_SAF_EOS_SHOVELINPROD_V]  
AS  
  
  
WITH CTE AS (  
SELECT   
siteflag,  
shiftflag,  
COUNT(ShovelID) TotalShovel  
FROM [saf].[CONOPS_SAF_SHOVEL_INFO_V]  
GROUP BY siteflag, shiftflag)  
  
SELECT   
a.siteflag,  
a.shiftflag,  
HOS,  
HR AS [Datetime],  
ROUND((TotalShovel * ((AVG(Avail)/100) * (AVG(UofA)/100))),0) AS ShovelInProd  
FROM [saf].[CONOPS_SAF_SP_SHOVEL_ASSET_EFFICIENCY_V] a  
LEFT JOIN CTE b ON a.shiftflag = b.shiftflag  
GROUP BY 
a.siteflag,
a.shiftflag,
HOS,
HR,
TotalShovel

  
  
