CREATE VIEW [TYR].[CONOPS_TYR_EOS_SHOVELINPROD_V] AS

  
  
  
--select * from [dbo].[CONOPS_TYR_EOS_SHOVELINPROD_V] where shiftflag = 'prev'  
CREATE VIEW [tyr].[CONOPS_TYR_EOS_SHOVELINPROD_V]  
AS  
  
  
WITH CTE AS (  
SELECT   
siteflag,  
shiftflag,  
COUNT(ShovelID) TotalShovel  
FROM [tyr].[CONOPS_TYR_SHOVEL_INFO_V]  
GROUP BY siteflag, shiftflag)  
  
SELECT   
a.siteflag,  
a.shiftflag,  
HOS,  
HR AS [Datetime],  
ROUND((TotalShovel * ((AVG(Avail)/100) * (AVG(UofA)/100))),0) AS ShovelInProd  
FROM [tyr].[CONOPS_TYR_SP_SHOVEL_ASSET_EFFICIENCY_V] a  
LEFT JOIN CTE b ON a.shiftflag = b.shiftflag  
GROUP BY 
a.siteflag,
a.shiftflag,
HOS,
HR,
TotalShovel
  
  
  
