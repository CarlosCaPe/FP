CREATE VIEW [SAF].[CONOPS_SAF_EOS_SHIFT_INFO_V] AS


  
  
  
  
  
--select * from [saf].[CONOPS_SAF_EOS_SHIFT_INFO_V] order by shiftflag  
CREATE VIEW [saf].[CONOPS_SAF_EOS_SHIFT_INFO_V]   
AS  

WITH TimeZone AS(
SELECT name AS TimeZoneName,
is_currently_dst,
CAST(CAST(current_utc_offset AS VARCHAR(3)) AS INT) AS current_utc_offset,
CAST(CAST(current_utc_offset AS VARCHAR(3)) AS INT) - DATEPART(TZ, SYSDATETIMEOFFSET()) / 60 AS current_server_offset
FROM sys.time_zone_info
WHERE name = 'US Mountain Standard Time'
)
  
SELECT sh.siteflag,  
       sh.shiftflag,  
       sh.shiftid,  
       (CONVERT(int, (DATEDIFF(DD, '7/12/2007', CAST(sh.ShiftStartDateTime AS DATE))*2) + 27412 +  
                    (SELECT RIGHT(sh.[ShiftId], 1) - 1))) ShiftIndex,  
       sh.ShiftStartDateTime,  
       sh.ShiftEndDateTime,
	   TRIM(sh.CrewID) AS CrewID,
	   sh.ShiftName,
	   sh.ShiftDuration,
		[TZ].TimeZoneName,
		[TZ].is_currently_dst,
		[TZ].current_utc_offset,
		[TZ].current_server_offset
FROM (  
  SELECT a.siteflag,  
            a.shiftflag,  
            a.shiftid,  
            CASE WHEN b.ShiftStartDateTime IS NULL   
       THEN (CASE WHEN right(a.shiftid, 1) = 1  
         THEN concat(cast(left(a.shiftid, 6) AS date), ' 07:15:00.000')  
       ELSE concat(cast(left(a.shiftid, 6) AS date), ' 19:15:00.000')  
        END)  
      ELSE b.ShiftStartDateTime  
            END AS ShiftStartDateTime,  
            CASE WHEN b.ShiftEndDateTime IS NULL  
     THEN (CASE WHEN right(a.shiftid, 1) = 1  
       THEN concat(cast(left(a.shiftid, 6) AS date), ' 19:15:00.000')  
                            ELSE concat(dateadd(DAY, 1, cast(left(a.shiftid, 6) AS date)), ' 07:15:00.000')  
                       END)  
                 ELSE b.ShiftEndDateTime  
            END AS ShiftEndDateTime,
	b.CrewID,
	b.ShiftName,
	b.ShiftDuration
     FROM  
         (SELECT siteflag,  
                 'CURR' AS shiftflag,  
                 max(prevshiftid) AS shiftid  
          FROM [saf].[shift_info] WITH (NOLOCK)  
    GROUP BY siteflag  
          UNION SELECT siteflag,  
                       'CURR' AS shiftflag,  
                       max(shiftid) AS shiftid  
          FROM [saf].[shift_info] WITH (NOLOCK)  
    GROUP BY siteflag  
          UNION SELECT siteflag,  
                       'PREV' AS shiftflag,  
                       max(prevshiftid) AS shiftid  
          FROM [saf].[shift_info] WITH (NOLOCK)  
    GROUP BY siteflag  
          UNION SELECT siteflag,  
                       'PREV' AS shiftflag,  
                       CASE  
                           WHEN RIGHT(max(prevshiftid), 1) = 2 THEN CONCAT(LEFT(max(prevshiftid), 8), '1')  
                           ELSE CONCAT(RIGHT(CONVERT(VARCHAR(8), DATEADD(DAY, -1, CONVERT(DATETIME, CONCAT('20', LEFT(max(prevshiftid), 6)), 112)), 112), 6), '002')  
                       END AS shiftid  
          FROM [saf].[shift_info] WITH (NOLOCK)  
    GROUP BY siteflag  
          UNION SELECT siteflag,  
                       'NEXT' AS shiftflag,  
                       max(shiftid) AS shiftid  
          FROM [saf].[shift_info] WITH (NOLOCK)  
    GROUP BY siteflag  
          UNION SELECT siteflag,  
                       'NEXT' AS shiftflag,  
                       CASE WHEN (SELECT nextshiftid  
                                  FROM (  
         SELECT TOP 1 nextshiftid,  
                                           ROW_NUMBER() OVER(PARTITION BY shiftid ORDER BY shiftid DESC) AS row_num  
                                    FROM [saf].[shift_info] WITH (NOLOCK)  
                                    ORDER BY shiftid DESC) AS nextshiftid) IS NULL  
       THEN (CASE WHEN RIGHT(max(shiftid), 1) = 2  
            THEN right(concat(replace(cast(dateadd(DAY, 1, cast(LEFT(max(shiftid), 6) AS date)) AS varchar(10)), '-', ''), '001'), 9)  
                                       ELSE right(concat(replace(cast(dateadd(DAY, 1, cast(LEFT(max(shi