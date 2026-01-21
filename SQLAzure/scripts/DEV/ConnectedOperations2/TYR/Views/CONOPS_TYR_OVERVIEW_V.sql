CREATE VIEW [TYR].[CONOPS_TYR_OVERVIEW_V] AS




--select * from [tyr].[CONOPS_TYR_OVERVIEW_V]
CREATE VIEW [TYR].[CONOPS_TYR_OVERVIEW_V]
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
     FROM [tyr].[CONOPS_TYR_SHIFT_OVERVIEW_V]
),

ShovelTarget AS(
SELECT
	siteflag,
	shiftid,
	ShovelId,
	SUM(ShovelShiftTarget) AS ShovelShiftTarget,
	SUM(ShovelTarget) AS ShovelTarget
FROM [tyr].[CONOPS_TYR_SHOVEL_SHIFT_TARGET_V]
GROUP BY siteflag, shiftid, ShovelId
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
	   tn.WasteMined,
       tn.TotalMaterialDeliveredToCrusher
FROM [tyr].[CONOPS_TYR_SHIFT_INFO_V] a WITH (NOLOCK)
LEFT JOIN TONS tn ON tn.shiftid = a.shiftid
--LEFT JOIN [tyr].[CONOPS_TYR_SHOVEL_TARGET_V] stg WITH (NOLOCK)
LEFT JOIN ShovelTarget stg WITH (NOLOCK)
ON a.shiftid = stg.shiftid AND tn.ShovelId = stg.shovelId





