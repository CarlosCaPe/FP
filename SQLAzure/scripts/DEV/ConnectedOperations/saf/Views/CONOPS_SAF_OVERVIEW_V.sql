CREATE VIEW [saf].[CONOPS_SAF_OVERVIEW_V] AS


--select * from [saf].[CONOPS_SAF_OVERVIEW_V]  
CREATE VIEW [saf].[CONOPS_SAF_OVERVIEW_V]  
AS  
  
  
WITH TONS AS (  
  SELECT shiftid,  
            ShovelId,  
            TotalMineralsMined,  
            TotalMaterialMined,
            MillOreMined,  
            ROMLeachMined,  
            CrushedLeachMined,  
            TotalMaterialDeliveredToCrusher  
     FROM [saf].[CONOPS_SAF_SHIFT_OVERVIEW_V]  
),  
     
TGT AS (  
  SELECT shiftid,  
            shovel,  
            sum(shovelshifttarget) AS shifttarget  
     FROM [saf].[CONOPS_SAF_SHOVEL_TARGET_V] (nolock)  
     GROUP BY shiftid, shovel  
),  
       
STGT AS (  
  SELECT shiftid,  
            shovelid,  
            sum(shoveltarget) AS shoveltarget  
     FROM [saf].[CONOPS_SAF_SHOVEL_SHIFT_TARGET_V]  
     GROUP BY shiftid, shovelid  
)  
  
SELECT a.shiftflag,  
       a.siteflag,  
       a.shiftid,  
       a.shiftindex,  
       tn.ShovelId,  
       stg.shoveltarget,  
       tg.shifttarget,  
       tn.TotalMineralsMined AS TotalMaterialMined,  
       tn.TotalMaterialMined TotalMaterialMoved,  
       tn.MillOreMined,  
       tn.ROMLeachMined,  
       tn.CrushedLeachMined,  
       tn.TotalMaterialDeliveredToCrusher  
FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] a  
LEFT JOIN TONS tn ON tn.shiftid = a.shiftid  
LEFT JOIN STGT stg ON a.shiftid = stg.shiftid  
AND stg.shovelid = tn.shovelid  
LEFT JOIN TGT tg ON CAST(a.shiftid AS VARCHAR(20)) = tg.shiftid  
AND tn.ShovelId = tg.shovel  
  
  
  

