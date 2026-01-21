CREATE VIEW [CHI].[CONOPS_CHI_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_DUMPTIME_V] AS
  
  
  
  
--select * from [chi].[CONOPS_CHI_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_DUMPTIME_V]  
CREATE VIEW [chi].[CONOPS_CHI_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_DUMPTIME_V]  
AS  
  
SELECT Shiftid,   
       [ShovelId],  
    shiftdumptime,  
       ISNULL(SUM(TotalMaterial), 0) AS TotalMaterialMoved ,  
    ISNULL(SUM([TotalExpit]), 0) AS TotalMaterialMined    
FROM (  
     SELECT [shiftid],  
            [ShovelId],  
   shiftdumptime,  
            SUM(LfTons) AS TotalMaterial ,  
            COUNT(LfTons) AS NrDumps ,  
            CASE  
                WHEN [Load] NOT LIKE 'ORE REHANDLE'  
                     AND (loc NOT LIKE 'ROADFILL%'   
      OR loc NOT LIKE 'OVERLOAD%') THEN SUM(Lftons)  
                ELSE 0  
            END AS [TotalExpit] ,  
            CASE  
                WHEN loc LIKE 'ROADFILL%' OR loc LIKE 'OVERLOAD%' THEN SUM(Lftons)  
                ELSE 0  
            END AS [TotalInpit] ,  
            CASE  
                WHEN ([Load] LIKE 'WASTE' OR [Load] LIKE 'AC_WASTE'  OR [Load] LIKE 'K_WASTE')  
    AND (loc NOT LIKE 'ROADFILL%' OR loc NOT LIKE 'OVERLOAD%')  
    THEN SUM(LfTons)  
                ELSE 0  
            END AS [TotalWaste] ,  
            CASE  
                WHEN [Load] LIKE 'ROM' AND loc NOT LIKE 'ROADFILL%' THEN SUM(LfTons)  
                ELSE 0  
            END AS [TotalLeach] ,  
            CASE  
                WHEN [Load] LIKE 'ORE REHANDLE' THEN SUM(LfTons)  
                ELSE 0  
            END AS [OreRehandletoCrusher] ,  
            CASE  
                WHEN [Load] LIKE 'ORE0%' AND loc NOT LIKE 'ROADFILL%' THEN SUM(LfTons)  
                ELSE 0  
            END AS [TotalExpitOre] ,  
            CASE  
                WHEN loc like 'CRUSHER' THEN SUM(LfTons)  
                ELSE 0  
            END AS [TotalCrushedMillOre] ,  
            CASE  
                WHEN [Load] LIKE 'ORE0%'  
                     AND loc like 'CRUSHER' THEN SUM(LfTons)  
                ELSE 0  
            END AS [ExpitOreToCrusher]  
     FROM (  
          SELECT enums.[DESCRIPTION] AS [Load],  
                 dumps.shiftid,  
                 s.FieldId AS [ShovelId],  
                 l.FieldId AS loc,  
                 --dumps.FieldLsizetons AS [LfTons]  
     dumps.FIELDLSIZEDB AS [LfTons],  
     dateadd(second,dumps.fieldtimedump,sinfo.shiftstartdatetime) as shiftdumptime   
          FROM chi.shift_dump_v dumps WITH (NOLOCK)  
    LEFT JOIN chi.shift_loc l WITH (NOLOCK) ON l.Id = dumps.FieldLoc  
          LEFT JOIN chi.shift_eqmt s WITH (NOLOCK)  ON s.Id = dumps.FieldExcav AND s.SHIFTID = dumps.shiftid  
          LEFT JOIN chi.shift_load loads WITH (NOLOCK) ON dumps.[FieldLoadRec] = loads.[Id]  
          LEFT JOIN chi.enum enums WITH (NOLOCK) ON enums.Id=dumps.FieldLoad  
   LEFT JOIN (  
      SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime)   
      OVER ( ORDER BY shiftid ) AS ShiftEndDateTime   
      from chi.[shift_info] WITH (NOLOCK)) sinfo ON dumps.shiftid = sinfo.shiftid  
          WHERE enums.Idx NOT IN (2)  
     ) AS Consolidated  
  WHERE ShovelId IS NOT NULL  
     GROUP BY Shiftid, ShovelId, [Load],  [loc],shiftdumptime  
) AS FINAL  
GROUP BY Shiftid, ShovelId,shiftdumptime  
  
  
  
