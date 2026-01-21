CREATE VIEW [cer].[ZZZ_CONOPS_CER_SHIFT_OVERVIEW_V_OLD] AS











--SELECT * FROM [cer].[CONOPS_CER_SHIFT_OVERVIEW_V] WHERE shiftid = '230121001'

CREATE VIEW [cer].[CONOPS_CER_SHIFT_OVERVIEW_V_OLD]
AS


SELECT  
	sdps.shiftid,
	sdps.ShovelId, 
	ISNULL(SUM(TotalMaterial), 0) AS TotalMaterialMined,
	ISNULL(SUM(NrDumps), 0) AS NrOfDumps,
	ISNULL(SUM(MillOre), 0) AS MillOreMined,
	ISNULL(SUM(Waste), 0) AS WasteMined,
	ISNULL(SUM(ROM), 0) AS ROMLeachMined,
	ISNULL(SUM(CrushedLeach), 0) AS CrushedLeachMined,
	ISNULL(SUM(TotalDeliveredToCrushers), 0) AS TotalMaterialDeliveredToCrusher,
	ISNULL(SUM(TotalStockedMaterial), 0) AS StockpiledOre
	  
FROM (
		SELECT  
			shiftid,
			ShovelId, 
			SUM(LfTons) AS TotalMaterial,
			COUNT(LfTons) AS NrDumps,
			CASE WHEN loc IN ('MILLCHAN','HIDRO-C1','MILLCRUSH1','MILLCRUSH2') THEN SUM(LfTons) ELSE 0 END AS MillOre,
			CASE WHEN loc NOT IN ('MILLCHAN','HIDRO-C1','MILLCRUSH1','MILLCRUSH2','HIDROCHAN') AND LEFT(loc,1)<>'S' AND LEFT(loc,3)<>'DIN' AND LEFT(loc,3)<>'P1X' AND LEFT(loc,5)<>'INPIT' THEN SUM(LfTons) ELSE 0 END AS Waste,
			CASE WHEN loc LIKE 'P1X%' THEN SUM(LfTons) ELSE 0 END AS ROM,
			CASE WHEN loc IN ('HIDROCHAN') THEN SUM(LfTons) ELSE 0 END AS CrushedLeach,
			CASE WHEN loc IN ('MILLCHAN','HIDRO-C1','MILLCRUSH1','MILLCRUSH2','HIDROCHAN') THEN SUM(LfTons) ELSE 0 END AS TotalDeliveredToCrushers,
			CASE WHEN (left(loc,1) ='S' or left(loc,3) ='DIN') AND right(loc,2) IN ('C1','C2','CL') THEN SUM(LfTons) ELSE 0 END AS TotalStockedMaterial
		FROM (
				SELECT    
					sd.ShiftId,
					s.FieldId AS [ShovelId],
					enum.Idx AS [Load],
					( SELECT TOP 1 FieldId FROM cer.shift_loc WITH (NOLOCK) WHERE shift_loc_id = sd.FieldLoc ) AS loc,
					sd.FieldLsizetons AS [LfTons],
					sd.FieldTimedump
				FROM cer.shift_dump sd
				LEFT JOIN cer.shift_loc sl ON sl.shift_loc_id = sd.FieldLoc
				LEFT JOIN cer.shift_eqmt s ON s.shift_eqmt_id = sd.FieldExcav
				LEFT JOIN cer.enum enum ON sd.FieldLoad = enum.enum_id
			) AS dumps
		WHERE ShovelId IS NOT NULL
    	GROUP BY Shiftid, ShovelId, [Load],  [loc]
	) AS sdps
GROUP BY shiftid, ShovelId


