CREATE VIEW [chi].[CONOPS_CHI_SHIFT_SNAPSHOT_V] AS






CREATE VIEW [chi].[CONOPS_CHI_SHIFT_SNAPSHOT_V]
AS

SELECT Shiftid, 
		shiftdumptime,
       [ShovelId],
       ISNULL(SUM(NrDumps), 0) AS NRDumps ,
       ISNULL(SUM(TotalMaterial), 0) AS TotalMaterialMined 
FROM (
     SELECT [shiftid],
			shiftdumptime,
            [ShovelId],
            SUM(LfTons) AS TotalMaterial ,
            COUNT(LfTons) AS NrDumps 
     FROM (
          SELECT enums.Idx AS [Load],
                 dumps.shiftid,
				dateadd(second,dumps.fieldtimedump,sinfo.shiftstartdatetime) as shiftdumptime ,
                 s.FieldId AS [ShovelId],
                 (SELECT TOP 1 FieldId FROM chi.shift_loc WITH (NOLOCK) WHERE Id = dumps.FieldLoc) AS loc,
                 dumps.FieldLsizedb AS [LfTons]
          FROM chi.shift_dump dumps WITH (NOLOCK)
          LEFT JOIN chi.shift_eqmt s WITH (NOLOCK)  ON s.Id = dumps.FieldExcav AND s.SHIFTID = dumps.shiftid
          LEFT JOIN chi.shift_load loads WITH (NOLOCK) ON dumps.[FieldLoadRec] = loads.[Id]
          LEFT JOIN chi.enum enums WITH (NOLOCK) ON enums.Id=dumps.FieldLoad
			LEFT JOIN (
			SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) 
			OVER ( ORDER BY shiftid ) AS ShiftEndDateTime 
			from [chi].[shift_info]) sinfo ON dumps.shiftid = sinfo.shiftid
          WHERE enums.Idx NOT IN (2)
     ) AS Consolidated
	 WHERE ShovelId IS NOT NULL
     GROUP BY Shiftid, ShovelId, [Load],  [loc],shiftdumptime
) AS FINAL
GROUP BY Shiftid, ShovelId,shiftdumptime

