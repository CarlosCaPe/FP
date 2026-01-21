CREATE VIEW [CHI].[CONOPS_CHI_OVERVIEW_V] AS


--select * from [chi].[CONOPS_CHI_OVERVIEW_V]
CREATE VIEW [chi].[CONOPS_CHI_OVERVIEW_V]
AS


WITH TONS AS (
	 SELECT shiftid,
            ShovelId,
            TotalMaterialMined AS TotalMineralsMined,
			TotalMaterialMoved,
            MillOreMined,
            ROMLeachMined,
            CrushedLeachMined,
            TotalMaterialDeliveredToCrusher
     FROM [chi].[CONOPS_CHI_SHIFT_OVERVIEW_V]
)

SELECT a.shiftflag,
       a.siteflag,
       a.shiftid,
       a.shiftindex,
       tn.ShovelId,
       stg.shovelshifttarget * ((a.ShiftDuration / 3600.00) / 12) AS shoveltarget,
       stg.shovelshifttarget AS shifttarget,
       tn.TotalMineralsMined AS TotalMaterialMined,
	   TotalMaterialMoved,
       tn.MillOreMined,
       tn.ROMLeachMined,
       tn.CrushedLeachMined,
       tn.TotalMaterialDeliveredToCrusher
FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] a WITH (NOLOCK)
LEFT JOIN TONS tn ON tn.shiftid = a.shiftid
LEFT JOIN [chi].[CONOPS_CHI_SHOVEL_TARGET_V] stg WITH (NOLOCK)
ON a.shiftid = stg.shiftid AND tn.ShovelId = stg.shovel



