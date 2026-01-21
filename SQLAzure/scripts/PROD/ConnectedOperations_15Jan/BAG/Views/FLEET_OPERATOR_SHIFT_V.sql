CREATE VIEW [BAG].[FLEET_OPERATOR_SHIFT_V] AS

CREATE VIEW BAG.FLEET_OPERATOR_SHIFT_V
AS

WITH OperatorLoginLogout AS(
SELECT
	OS.OPERATORSHIFT_OID,
	RIGHT(CAST(shift.reporting_date AS VARCHAR), 6) + '00' + CAST(shift.shifttype + 1 AS VARCHAR) AS SHIFTID,
	shift.starttime_utc AS SHIFT_START_UTC,
	shift.endtime_utc AS SHIFT_END_UTC,
	CASE WHEN shift.starttime_utc >= OS.LOGIN_UTC THEN shift.starttime_utc ELSE OS.LOGIN_UTC END AS LOGIN_UTC,
	CASE WHEN shift.endtime_utc <= COALESCE(LOGOUT_UTC, GETUTCDATE()) THEN shift.endtime_utc ELSE COALESCE(LOGOUT_UTC, GETUTCDATE()) END AS LOGOUT_UTC,
	OS.OPERATOR,
	OS.MACHINE
FROM BAG_MSHist.dbo.OperatorShift OS
INNER JOIN BAG_MSMODEL.dbo.SHIFT SHIFT
	ON (
			(
				shift.starttime_utc >= OS.LOGIN_UTC
				AND shift.starttime_utc < COALESCE(LOGOUT_UTC, GETUTCDATE())
			)
			OR (
				shift.endtime_utc > OS.LOGIN_UTC
				AND shift.endtime_utc <= COALESCE(LOGOUT_UTC, GETUTCDATE())
			)
		)
WHERE LOGIN_UTC >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE))

UNION

SELECT
	OS.OPERATORSHIFT_OID,
	RIGHT(CAST(shift.reporting_date AS VARCHAR), 6) + '00' + CAST(shift.shifttype + 1 AS VARCHAR) AS SHIFTID,
	shift.starttime_utc AS SHIFT_START_UTC,
	shift.endtime_utc AS SHIFT_END_UTC,
	CASE WHEN shift.starttime_utc >= OS.LOGIN_UTC THEN shift.starttime_utc ELSE OS.LOGIN_UTC END AS LOGIN_UTC,
	CASE WHEN shift.endtime_utc <= COALESCE(LOGOUT_UTC, GETUTCDATE()) THEN shift.endtime_utc ELSE COALESCE(LOGOUT_UTC, GETUTCDATE()) END AS LOGOUT_UTC,
	OS.OPERATOR,
	OS.MACHINE
FROM BAG_MSHist.dbo.OperatorShift OS
INNER JOIN BAG_MSMODEL.dbo.SHIFT SHIFT
	ON (
			(
				OS.LOGIN_UTC BETWEEN shift.starttime_utc
					AND shift.endtime_utc
			)
			AND (
				COALESCE(LOGOUT_UTC, GETUTCDATE()) BETWEEN shift.starttime_utc
					AND shift.endtime_utc
			)
		)
WHERE LOGIN_UTC >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE))
),

TimeZone AS(
SELECT 
	name AS TimeZoneName,
	is_currently_dst,
	CAST(CAST(current_utc_offset AS VARCHAR(3)) AS INT) AS current_utc_offset,
	CAST(CAST(current_utc_offset AS VARCHAR(3)) AS INT) - DATEPART(TZ, SYSDATETIMEOFFSET()) / 60 AS current_server_offset
FROM sys.time_zone_info
WHERE name = 'US Mountain Standard Time'
)

SELECT
	OP.OPERATORSHIFT_OID,
	OP.SHIFTID COLLATE SQL_Latin1_General_CP1_CI_AS AS SHIFTID,
	M.NAME COLLATE SQL_Latin1_General_CP1_CI_AS AS MACHINE_NAME,
	MCA.NAME COLLATE SQL_Latin1_General_CP1_CI_AS AS MACHINE_CATEGORY,
	CM.DISPATCH_EQUIP_CATEGORY_NUMBER AS UNIT,
	P.PERSONNELID COLLATE SQL_Latin1_General_CP1_CI_AS AS OPERATOR_ID,
	P.NAME COLLATE SQL_Latin1_General_CP1_CI_AS AS OPERATOR_NAME,
	DATEADD(HOUR, current_utc_offset, SHIFT_START_UTC) AS SHIFT_START_LOCAL_TIME,
	DATEADD(HOUR, current_utc_offset, SHIFT_END_UTC) AS SHIFT_END_LOCAL_TIME,
	DATEADD(HOUR, current_utc_offset, LOGIN_UTC) AS LOGIN_LOCAL_TIME,
	DATEDIFF(SECOND, SHIFT_START_UTC, LOGIN_UTC) AS LOGIN_TIME,
	DATEADD(HOUR, current_utc_offset, LOGOUT_UTC) AS LOGOUT_LOCAL_TIME,
	DATEDIFF(SECOND, SHIFT_START_UTC, LOGOUT_UTC) AS LOGOUT_TIME
FROM OperatorLoginLogout OP
LEFT JOIN BAG_MSMODEL.dbo.PERSON P WITH(NOLOCK)
	ON P.PERSON_OID = OP.OPERATOR
LEFT JOIN BAG_MSMODEL.dbo.MACHINE M WITH(NOLOCK)
	ON M.MACHINE_OID = OP.MACHINE
LEFT JOIN BAG_MSMODEL.dbo.MACHINECLASS MCL WITH(NOLOCK)
	ON m.class = MCL.machineclass_oid
LEFT JOIN BAG_MSMODEL.dbo.MACHINECATEGORY MCA WITH(NOLOCK)
	ON MCL.category = MCA.machinecategory_oid
LEFT JOIN BAG.LH_EQUIP_CATEGORY_MAP CM WITH(NOLOCK)
	ON MCA.NAME COLLATE SQL_Latin1_General_CP1_CI_AS = CM.FLEET_EQUIP_CATEGORY
CROSS JOIN TimeZone tz

