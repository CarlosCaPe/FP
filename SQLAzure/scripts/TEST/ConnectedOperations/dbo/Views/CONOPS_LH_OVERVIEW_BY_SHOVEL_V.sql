CREATE VIEW [dbo].[CONOPS_LH_OVERVIEW_BY_SHOVEL_V] AS







--select * from [dbo].[CONOPS_LH_OVERVIEW_BY_SHOVEL_V] where shiftflag = 'curr'
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
from [saf].[CONOPS_SAF_OVERVIEW_V] (NOLOCK)
where siteflag = 'SAF'
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
from [sie].[CONOPS_SIE_OVERVIEW_V] (NOLOCK)
where siteflag = 'SIE'
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
from [cli].[CONOPS_CLI_OVERVIEW_V] (NOLOCK)
where siteflag = 'CMX'
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
from [chi].[CONOPS_CHI_OVERVIEW_V] (NOLOCK)
where siteflag = 'CHI'
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
from [cer].[CONOPS_CER_OVERVIEW_V] (NOLOCK)
where siteflag = 'CER'
group by siteflag,shiftflag,shiftindex,Shovelid,shiftid,ShiftTarget

