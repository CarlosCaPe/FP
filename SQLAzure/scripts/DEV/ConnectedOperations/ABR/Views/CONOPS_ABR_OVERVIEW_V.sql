CREATE VIEW [ABR].[CONOPS_ABR_OVERVIEW_V] AS




--select * from [abr].[CONOPS_ABR_OVERVIEW_V]
CREATE VIEW [abr].[CONOPS_ABR_OVERVIEW_V]
AS


WITH TONS AS (
	 SELECT shiftid,
            ShovelId,
            TotalMaterialMined AS TotalMineralsMined,
			TotalMaterialMoved,
            MillOreMined,
            ROMLeachMined,
			WasteMined,
            CrushedLeachMined,
            TotalMaterialDeliveredToCrusher
     FROM [abr].[CONOPS_ABR_SHIFT_OVERVIEW_V]
)

SELECT a.shiftflag,
       a.siteflag,
       a.shiftid,
       a.shiftindex,
       tn.ShovelId,
       ShovelTarget,
       ShovelShiftTarget AS shifttarget,
	   tn.TotalMineralsMined AS TotalMaterialMined,
	   TotalMaterialMoved,
       tn.MillOreMined,
       tn.ROMLeachMined,
       tn.CrushedLeachMined,
	   tn.WasteMined,
       tn.TotalMaterialDeliveredToCrusher
FROM [abr].[CONOPS_ABR_SHIFT_INFO_V] a WITH (NOLOCK)
LEFT JOIN TONS tn ON tn.shiftid = a.shiftid
LEFT JOIN (
SELECT
Shiftid,
ShovelId,
SUM(ShovelTarget) AS ShovelTarget,
SUM(ShovelShiftTarget) AS ShovelShiftTarget
FROM [abr].[CONOPS_ABR_SHOVEL_SHIFT_TARGET_V]
GROUP BY Shiftid,ShovelId) stg 
ON a.shiftid = stg.shiftid AND tn.ShovelId = stg.shovelId



