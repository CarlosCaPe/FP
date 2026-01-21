CREATE VIEW [cer].[CONOPS_CER_OVERVIEW_V] AS

--select * from [cer].[CONOPS_CER_OVERVIEW_V]
CREATE VIEW [cer].[CONOPS_CER_OVERVIEW_V]
AS


WITH TONS AS
  (SELECT shiftid,
          ShovelId,
          TotalMaterialMined,
		  TotalMaterialMoved,
          MillMined AS MillOreMined,
          ROMMined AS ROMLeachMined,
          CrushLeachMined AS CrushedLeachMined,
          TotalMaterialDeliveredToCrusher
   FROM [cer].[CONOPS_CER_SHIFT_OVERVIEW_V]
),

TGT AS (
	 SELECT shiftid,
            shovel,
            sum(shovelshifttarget) AS shifttarget
     FROM [cer].[CONOPS_CER_SHOVEL_TARGET_V] (nolock)
     GROUP BY shiftid, shovel
),

STGT AS ( 
	SELECT shiftid,
          shovelid,
          sum(shoveltarget) AS shoveltarget
	FROM [cer].[CONOPS_CER_SHOVEL_SHIFT_TARGET_V]
	GROUP BY shiftid, shovelid
)

SELECT a.shiftflag,
       a.siteflag,
       a.shiftid,
       a.shiftindex,
       tn.ShovelId,
       stg.shoveltarget,
       tg.shifttarget,
       tn.TotalMaterialMined,
	   tn.TotalMaterialMoved,
       tn.MillOreMined,
       tn.ROMLeachMined,
       tn.CrushedLeachMined,
       tn.TotalMaterialDeliveredToCrusher
FROM [cer].[CONOPS_CER_SHIFT_INFO_V] a
LEFT JOIN TONS tn ON tn.shiftid = a.shiftid
LEFT JOIN STGT stg ON a.shiftid = stg.shiftid
AND stg.shovelid = tn.shovelid
LEFT JOIN TGT tg ON a.shiftid = tg.shiftid
AND tn.ShovelId = tg.Shovel


