CREATE VIEW [mor].[ZZZ_CONOPS_MOR_MATERIAL_DELIVERED_TO_CHRUSHER_V_BUP] AS











--select * from [mor].[CONOPS_MOR_MATERIAL_DELIVERED_TO_CHRUSHER_V]

CREATE VIEW [mor].[CONOPS_MOR_MATERIAL_DELIVERED_TO_CHRUSHER_V] 
AS

WITH CTE AS (
SELECT   
shiftid,
siteflag,
CASE WHEN [loc] IN ( '849-MFL', 'C2MFL', 'C2MIL' )
         THEN 'Crusher 2'
         WHEN [loc] IN ( '859-MILL', 'C3MFL', 'C3MIL' )
         THEN 'Crusher 3'
         ELSE NULL
         END AS CrusherLoc ,
		 CASE WHEN loc IN ( 'C2MIL', 'C3MIL' ) THEN SUM(LfTons)
			  ELSE 0
		 END AS DumpLoc2Tons ,
		 CASE WHEN loc IN ( 'C2MIL', 'C3MIL' ) THEN AVG(DumpTime)
			  ELSE 0
		 END AS DumpLoc2AverageDumpTime ,
		 CASE WHEN loc IN ( 'C2MIL', 'C3MIL' ) THEN AVG(IdleTime)
			  ELSE 0
		 END AS DumpLoc2AverageIdleTime ,
		 CASE WHEN loc IN ( 'C2MIL', 'C3MIL' ) THEN COUNT(LfTons)
			  ELSE 0
		 END AS DumpLoc2NrDumps ,
		 CASE WHEN loc IN ( 'C2MIL', 'C3MIL' ) THEN SUM(LfTons)
			  ELSE 0
		 END AS MillOreDeliveredToCrusher ,
		 CASE WHEN loc IN ( 'C2MIL', 'C3MIL' ) THEN AVG(DumpTime)
			  ELSE 0
		 END AS MillOreAverageDumpTime ,
		 CASE WHEN loc IN ( 'C2MIL', 'C3MIL' ) THEN AVG(IdleTime)
			  ELSE 0
		 END AS MillOreAverageIdleTime ,
		 CASE WHEN loc IN ( 'C2MIL', 'C3MIL' ) THEN COUNT(LfTons)
			  ELSE 0
		 END AS MillNrDumps ,
		 CASE WHEN loc IN ( 'C2MFL', 'C3MFL' ) THEN SUM(LfTons)
			  ELSE 0
		 END AS MflDeliveredToCrusher ,
		 CASE WHEN loc IN ( 'C2MFL', 'C3MFL' ) THEN AVG(DumpTime)
			  ELSE 0
		 END AS MflAverageDumpTime ,
		 CASE WHEN loc IN ( 'C2MFL', 'C3MFL' ) THEN AVG(IdleTime)
			  ELSE 0
		 END AS MflAverageIdleTime ,
		 CASE WHEN loc IN ( 'C2MFL', 'C3MFL' ) THEN COUNT(LfTons)
			  ELSE 0
		 END AS MflNrDumps
 FROM    ( SELECT    enums.Idx AS [Load] ,dumps.shiftid,dumps.siteflag,
					 ( SELECT TOP 1
								 FieldId
					   FROM      mor.shift_loc WITH (NOLOCK)
					   WHERE     Id = dumps.FieldLoc
					 ) AS loc ,
					 ( CAST(dumps.FieldTimeempty AS FLOAT)
					   - CAST(dumps.FieldTimedump AS FLOAT) ) / 60 AS DumpTime ,
					 ( CAST(dumps.FieldTimedump AS FLOAT)
					   - CAST(dumps.FieldTimearrive AS FLOAT) ) / 60 AS IdleTime ,
					 ( SELECT TOP 1
								 COALESCE(SSE.[FieldSize], 0)
					   FROM      mor.shift_eqmt SSE WITH (NOLOCK)
					   WHERE     SSE.Id = dumps.FieldTruck
								 AND SSE.ShiftId = dumps.[OrigShiftid]
					 ) AS [LfTons]
		   FROM      mor.shift_dump_v dumps WITH (NOLOCK)
					 LEFT JOIN mor.shift_load (nolock) loads ON dumps.[FieldLoadRec] = loads.[Id]
					 LEFT JOIN mor.Enum (nolock) enums ON enums.Id = dumps.FieldLoad
		   WHERE     enums.Idx NOT IN ( 26, 27, 28, 29, 30 )
					 AND ( SELECT TOP 1
									 FieldId
						   FROM      mor.shift_loc WITH (NOLOCK)
						   WHERE     Id = dumps.FieldLoc
						 ) IN ( 'C2MIL', 'C3MIL', 'C2MFL', 'C3MFL' )
					 
		 ) AS Consolidated
 
 GROUP BY loc,shiftid,siteflag)

 SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
b.CrusherLoc,
b.MflDeliveredToCrusher [CrusherLeach],
b.MillOreDeliveredToCrusher [MillOre]
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] a WITH (NOLOCK)
LEFT JOIN CTE b WITH (NOLOCK)
on a.shiftid = b.shiftid AND a.siteflag = b.siteflag


