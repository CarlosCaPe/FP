CREATE VIEW [CLI].[CONOPS_CLI_DAILY_SHOVEL_SHIFT_TARGET_V] AS
  
  
  
--select * from [cli].[CONOPS_CLI_DAILY_SHOVEL_SHIFT_TARGET_V] where shiftflag = 'curr'  
  
CREATE VIEW [cli].[CONOPS_CLI_DAILY_SHOVEL_SHIFT_TARGET_V]  
AS  
  
  
WITH CTE AS (  
SELECT   
case when right(shiftid,1) = 1   
THEN concat(right(replace(cast(LEFT(shiftid,CHARINDEX('-', shiftid) - 1) as date),'-',''),6),'001')  
ELSE concat(right(replace(cast(LEFT(shiftid,CHARINDEX('-', shiftid) - 1) as date),'-',''),6),'002')  
END AS Formatshiftid,  
shovel,  
sum(WasteTons) As WasteShiftTarget,  
sum(TotalTonstoCrusher) AS CrusherShiftTarget,  
sum(TotalMillOreMined) AS MillOreShiftTarget,  
sum(TotalTonsMined) as shovelshifttarget  
from [cli].[plan_values] WITH (NOLOCK)  
group by shiftid, shovel)  
  
SELECT  
siteflag,  
shiftflag,  
shiftid,  
shovel as shovelid,  
SHIFTDURATION/3600.0 AS ShiftCompleteHour,  
WasteShiftTarget,  
((SHIFTDURATION/3600.0)/12.0) * WasteShiftTarget AS WasteTarget,  
CrusherShiftTarget,  
((SHIFTDURATION/3600.0)/12.0) * CrusherShiftTarget AS CrusherTarget,  
MillOreShiftTarget,  
((SHIFTDURATION/3600.0)/12.0) * MillOreShiftTarget AS MillOreTarget,  
shovelshifttarget,  
((SHIFTDURATION/3600.0)/12.0) * shovelshifttarget AS ShovelTarget  
FROM [cli].[CONOPs_CLI_EOS_SHIFT_INFO_V] a  
LEFT JOIN CTE b ON a.shiftid = b.Formatshiftid  
  
  
