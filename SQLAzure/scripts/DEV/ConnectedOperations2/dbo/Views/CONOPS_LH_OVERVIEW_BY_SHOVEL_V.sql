CREATE VIEW [dbo].[CONOPS_LH_OVERVIEW_BY_SHOVEL_V] AS


CREATE VIEW [dbo].[CONOPS_LH_OVERVIEW_BY_SHOVEL_V]
AS


SELECT 
siteflag,
shiftflag,
shiftindex,
shiftid,
Shovelid, 
sum(TotalMaterialMined) AS Actualvalue, 
ShiftTarget,
sum(shoveltarget) as shoveltarget
from [mor].[CONOPS_MOR_OVERVIEW_V] (NOLOCK)
where siteflag = 'MOR'
group by siteflag,shiftflag,shiftindex,Shovelid,shiftid,ShiftTarget 


UNION ALL


SELECT 
siteflag,
shiftflag,
shiftindex,
shiftid,
Shovelid, 
sum(TotalMaterialMined) AS Actualvalue, 
ShiftTarget,
sum(shoveltarget) as shoveltarget
from [bag].[CONOPS_BAG_OVERVIEW_V] (NOLOCK)
where siteflag = 'BAG'
group by siteflag,shiftflag,shiftindex,Shovelid,shiftid,ShiftTarget


