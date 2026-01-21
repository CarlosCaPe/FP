CREATE VIEW [CER].[SHIFT_INFO] AS

--SELECT * FROM CER.SHIFT_INFO
CREATE VIEW [CER].[SHIFT_INFO]
AS

WITH TimeZone AS(
SELECT
	name AS TimeZoneName,
	is_currently_dst,
	CAST(CAST(current_utc_offset AS VARCHAR(3)) AS INT) AS current_utc_offset,
	CAST(CAST(current_utc_offset AS VARCHAR(3)) AS INT) - DATEPART(TZ, SYSDATETIMEOFFSET()) / 60 AS current_server_offset
FROM sys.time_zone_info
WHERE name = 'SA Pacific Standard Time'
),

ShiftInfoCTE AS(
SELECT
	LEFT(s.Id, 9) AS ShiftId,
	REPLACE( STR(s.FieldYear, 2) + STR(m.Idx, 2) + STR(s.FieldDay, 2) + LEFT(LOWER(st.Abbreviation), 1), ' ', '0' ) AS ShiftName,
	REPLACE( 'sh' + STR(s.FieldYear, 2) + STR(m.Idx, 2) + STR(s.FieldDay, 2) + LEFT(LOWER(st.Abbreviation), 1) + '.ddb', ' ', '0' ) AS DbName,
	s.FieldYear AS ShiftYear,
	m.Idx AS ShiftMonth,
	s.FieldDay AS ShiftDay,
	LEFT(LOWER(st.Abbreviation), 1) AS ShiftSuffix,
	st.Description AS FullShiftSuffix,
	s.FieldStart AS ShiftStartSecSinceMidnight,
	DATEDIFF( ss, '1970-01-01', CONVERT( datetime, REPLACE( '20' + STR(s.FieldYear, 2) + STR(m.Idx, 2) + STR(s.FieldDay, 2), ' ', '0' ) ) ) + s.FieldStart AS ShiftStartTimestamp,
	s.FieldUtcstart AS ShiftStartTimestampUtc,
	CONVERT( datetime, CONVERT( date, DATEADD( ss, s.FieldStart, CONVERT( datetime, REPLACE( '20' + STR(s.FieldYear, 2) + STR (m.Idx, 2) + STR(s.FieldDay, 2), ' ', '0' ) ) ) ) ) AS ShiftStartDate,
	DATEADD( ss, s.FieldStart, CONVERT( datetime, REPLACE( '20' + STR(s.FieldYear, 2) + STR(m.Idx, 2) + STR(s.FieldDay, 2 ), ' ', '0' ) ) ) AS ShiftStartDateTime,
	REPLACE(STR(s.FieldDay, 2), ' ', '0') + '-' + m.Description + '-' + '20' + REPLACE(STR(s.FieldYear, 2), ' ', '0') + ' ' + st.Description AS FullShiftName,
	s.FieldHoliday AS [Holiday],
	c.Description AS [Crew],
	s.FieldTime AS ShiftDuration,
	REPLACE(STR(s.FieldDay, 2), ' ', '0') + '-' + m.Description + '-' + REPLACE(STR(s.FieldYear, 2), ' ', '0') AS ShiftDate 
FROM
	[CVEOperational].[dbo].SHIFTRootShiftdate AS s WITH (NOLOCK) 
	INNER JOIN
		[CVEOperational].[dbo].Enum AS m WITH (NOLOCK) 
		ON s.FieldMonth = m.Id 
	INNER JOIN
		[CVEOperational].[dbo].Enum AS st WITH (NOLOCK) 
		ON s.FieldShift = st.Id 
	INNER JOIN
		[CVEOperational].[dbo].Enum AS c WITH (NOLOCK) 
		ON s.FieldCrew = c.Id 
),

Last4Shift AS(
SELECT
	TOP 4 'CER' AS SiteFlag,
	LAG(ShiftId) OVER (ORDER BY ShiftId) AS PrevShiftId,
	ShiftId,
	LEAD(ShiftId) OVER (ORDER BY ShiftId) AS NextShiftId,
	ShiftName,
	DbName,
	ShiftYear,
	ShiftMonth,
	ShiftDay,
	ShiftSuffix,
	FullShiftSuffix,
	ShiftStartSecSinceMidnight,
	ShiftStartTimestamp,
	ShiftStartTimestampUtc,
	ShiftStartDate,
	ShiftStartDateTime,
	LEAD(ShiftStartDateTime) OVER (ORDER BY SHIFTID) AS ShiftEndDateTime,
	FullShiftName,
	Holiday,
	Crew,
	ShiftDuration,
	ShiftDate 
FROM
	ShiftInfoCTE 
ORDER BY
	ShiftId DESC 
)

SELECT
	SiteFlag
	,PrevShiftId
	,ShiftId
	,NextShiftId
	,ShiftName
	,DbName
	,ShiftYear
	,ShiftMonth
	,ShiftDay
	,ShiftSuffix
	,FullShiftSuffix
	,ShiftStartSecSinceMidnight
	,ShiftStartTimestamp
	,ShiftStartTimestampUtc
	,ShiftStartDate
	,ShiftStartDateTime
	,DATEADD(HOUR, 12, ShiftStartDateTime) AS ShiftEndDateTime
	,FullShiftName
	,Holiday
	,Crew
	,ShiftDuration
	,ShiftDate
	,((DATEDIFF(DAY, '1970-01-01', CAST(ShiftStartDateTime AS DATE))) * 2 + ((shiftid - 1) % 2)) * 10 AS ShiftIndex
	,TimeZoneName
	,is_currently_dst
	,current_utc_offset
	,current_server_offset
FROM Last4Shift si
CROSS JOIN TimeZone TZ

