CREATE VIEW [CER].[CONOPS_CER_SHIFT_SNAPSHOT_V] AS



CREATE VIEW [cer].[CONOPS_CER_SHIFT_SNAPSHOT_V]
AS

SELECT  
	sdps.shiftid,
	sdps.shiftdumptime,
	sdps.ShovelId, 
	ISNULL(SUM(TotalMaterialMined), 0) AS TotalMaterialMined,
	ISNULL(SUM(NrDumps), 0) AS NrOfDumps  
FROM (
		SELECT  
			shiftid,
			shiftdumptime,
			ShovelId, 
			SUM(CASE WHEN dumps.[Load] IN (0,1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,23,31,32,34,36,37,38,39) THEN LfTons ELSE 0 END) AS TotalMaterialMined,
			COUNT(LfTons) AS NrDumps
		FROM (
				SELECT    
					sd.ShiftId,
					dateadd(second,sd.fieldtimedump,si.shiftstartdatetime) as shiftdumptime ,
					s.FieldId AS [ShovelId],
					enum.Idx AS [Load],
					( SELECT TOP 1 FieldId FROM cer.shift_loc WITH (NOLOCK) WHERE shift_loc_id = sd.FieldLoc ) AS loc,
					sd.FieldLsizetons AS [LfTons],
					sd.FieldTimedump
				FROM cer.shift_dump_v sd
				LEFT JOIN cer.shift_loc sl ON sl.shift_loc_id = sd.FieldLoc
				LEFT JOIN cer.shift_eqmt s ON s.shift_eqmt_id = sd.FieldExcav
				LEFT JOIN cer.enum enum ON sd.FieldLoad = enum.enum_id
				LEFT JOIN cer.shift_info si ON sd.ShiftId = si.ShiftId
			) AS dumps
		WHERE ShovelId IS NOT NULL
    	GROUP BY Shiftid, ShovelId, [Load],  [loc],shiftdumptime
	) AS sdps
GROUP BY shiftid, ShovelId,shiftdumptime


