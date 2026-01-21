CREATE VIEW [mor].[CONOPS_MOR_TRUCK_DUMPING_TO_CRUSHER_V] AS




--select * from [mor].[CONOPS_MOR_TRUCK_DUMPING_TO_CRUSHER_V] where shiftflag = 'prev'
CREATE VIEW [mor].[CONOPS_MOR_TRUCK_DUMPING_TO_CRUSHER_V]
AS
SELECT [shift].shiftflag,
	   'MOR' siteflag,
	   [Truck],
	   [totalDump]
FROM [dbo].[SHIFT_INFO_V] [shift]

LEFT JOIN (
SELECT ShiftId,
	   FieldId [Truck],
	   SUM([LfTons]) [totalDump]
FROM
(
	SELECT  dumps.ShiftId,
			t.FieldId,
			( SELECT TOP 1
						FieldId
			FROM      mor.shift_loc WITH (NOLOCK)
			WHERE     Id = dumps.FieldLoc
			) AS loc ,
			( SELECT TOP 1
						COALESCE(SSE.[FieldSize], 0)
			FROM      mor.shift_eqmt SSE WITH (NOLOCK)
			WHERE     SSE.Id = dumps.FieldTruck
						AND SSE.ShiftId = dumps.ShiftId
			) AS [LfTons]
	FROM    mor.shift_dump_v dumps WITH (NOLOCK)
			LEFT JOIN mor.Enum enums (NOLOCK) ON enums.Id = dumps.FieldLoad
			LEFT JOIN mor.shift_eqmt e (NOLOCK) ON e.Id = dumps.FieldExcav
			LEFT JOIN mor.[pit_excav_c] s (NOLOCK) ON e.FieldId = s.FieldId
			LEFT JOIN mor.[pit_truck_c] t (NOLOCK) ON t.FieldExcav = s.Id
	WHERE   enums.Idx NOT IN ( 26, 27, 28, 29, 30 )
			AND ( SELECT TOP 1 FieldId
				  FROM mor.shift_loc WITH (NOLOCK)
				  WHERE Id = dumps.FieldLoc) IN ( 'C2MIL', 'C3MIL', 'C2MFL', 'C3MFL' )
	) [a]
	GROUP BY ShiftId, FieldId 
) [dtc]
on  [dtc].ShiftId = [shift].shiftid

