-- =============================================
-- Author:		sxavier
-- Create date:
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[GetShiftDateTimeSiteMorenci]
(	
	@SelectedDateTime DATETIME
)
RETURNS TABLE 
AS
RETURN 
(
	WITH 
	TimeZone AS(
		SELECT
			NAME AS TimeZoneName,
			is_currently_dst,
			CAST(CAST(current_utc_offset AS VARCHAR(3)) AS INT) AS current_utc_offset,
			CAST(CAST(current_utc_offset AS VARCHAR(3)) AS INT) - DATEPART(TZ, SYSDATETIMEOFFSET()) / 60 AS current_server_offset
		FROM sys.time_zone_info
		WHERE name = 'US Mountain Standard Time'
	),
	Datetime_List AS(
		SELECT 
			'CURR' AS shiftflag,
			DATEADD(HOUR, current_utc_offset, @SelectedDateTime) AS Site_Datetime
		FROM 
			TimeZone
	),
	ShiftCode_List AS(
		SELECT
			'MOR' AS siteflag,
			shiftflag,
			Site_Datetime,
			CASE WHEN CAST(Site_Datetime AS TIME) BETWEEN '07:15:00' AND '19:15:00' THEN 'D' ELSE 'N' END AS ShiftCode,
			CAST(Site_Datetime AS TIME) AS ShiftHour
		FROM 
			Datetime_List
	),
	ShiftStartDate_List AS(
		SELECT
			siteflag,
			shiftflag,
			Site_Datetime,
			ShiftCode,
			CASE WHEN ShiftCode = 'N' AND ShiftHour BETWEEN '00:00:00' AND '07:15:00'
				THEN CAST(CAST(DATEADD(DAY, -1, Site_Datetime) AS DATE) AS DATETIME)
			ELSE CAST(CAST(Site_Datetime AS DATE) AS DATETIME)
				END AS ShiftStartDate
		FROM 
			ShiftCode_List
	),
	ShiftStart AS(
		SELECT
			siteflag,
			shiftflag,
			Site_Datetime,
			ShiftStartDate,
			ShiftCode,
			CASE WHEN ShiftCode = 'D'
				THEN CONCAT(CONVERT(VARCHAR(6), ShiftStartDate, 12), '001')
				ELSE CONCAT(CONVERT(VARCHAR(6), ShiftStartDate, 12), '002')
				END AS shiftid,
			CASE WHEN ShiftCode = 'D'
				THEN DATEADD(MINUTE, 15, DATEADD(HOUR, 7, ShiftStartDate))
			ELSE DATEADD(MINUTE, 15, DATEADD(HOUR, 19, ShiftStartDate))
				END AS ShiftStartDatetime
		FROM ShiftStartDate_List
	),
	Final AS(
		SELECT
			siteflag,
			shiftflag,
			shiftid,
			((DATEDIFF(DAY, '1970-01-01', ShiftStartDate) * 2) + ((CAST(RIGHT(shiftid, 1) AS INT) -1) % 2)) AS ShiftIndex,
			ShiftStartDatetime,
			DATEADD(HOUR, 12, ShiftStartDatetime) AS ShiftEndDateTime,
			ShiftCode,
			TimeZoneName,
			is_currently_dst,
			current_utc_offset,
			current_server_offset
		FROM ShiftStart
		CROSS JOIN TimeZone
	)

	SELECT
		a.siteflag,
		a.shiftflag,
		a.ShiftStartDatetime,
		a.ShiftEndDatetime,
		DATEADD(HOUR, -a.current_utc_offset, a.ShiftStartDatetime) AS UtcShiftStartDateTime,
		DATEADD(HOUR, -a.current_utc_offset, a.ShiftEndDateTime) AS UtcShiftEndDateTime,
		a.ShiftCode,
		is_currently_dst,
		current_utc_offset,
		current_server_offset
	FROM Final a
	WHERE a.shiftflag IN ('CURR')
	)
