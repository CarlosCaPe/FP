CREATE VIEW [MOR].[CONOPS_MOR_SHIFT_INFO_V] AS



  
--SELECT * FROM [MOR].[CONOPS_MOR_SHIFT_INFO_V]    
CREATE VIEW [mor].[CONOPS_MOR_SHIFT_INFO_V]      
AS    

WITH TimeZone AS(
SELECT name AS TimeZoneName,
is_currently_dst,
CAST(CAST(current_utc_offset AS VARCHAR(3)) AS INT) AS current_utc_offset,
CAST(CAST(current_utc_offset AS VARCHAR(3)) AS INT) - DATEPART(TZ, SYSDATETIMEOFFSET()) / 60 AS current_server_offset
FROM sys.time_zone_info
WHERE name = 'US Mountain Standard Time'
)

SELECT [S].SITEFLAG,    
    [S].SHIFTFLAG,    
    [S].SHIFTID,    
    (CONVERT(INT, (DATEDIFF(DD, '7/12/2007', CAST(SHIFTSTARTDATETIME AS DATE))*2) + 27412 + (SELECT RIGHT([SHIFTID],1) - 1))) SHIFTINDEX,    
    [S].SHIFTSTARTDATETIME,    
    [S].SHIFTENDDATETIME,    
    [S].SHIFTDURATION,
	TRIM([S].CrewID) AS CrewID,
	[S].ShiftStartDate,
	[S].ShiftName,
	[TZ].TimeZoneName,
	[TZ].is_currently_dst,
	[TZ].current_utc_offset,
	[TZ].current_server_offset
FROM (    
 SELECT A.SITEFLAG,    
     A.SHIFTFLAG,    
     A.SHIFTID,    
     CASE WHEN B.SHIFTSTARTDATETIME IS NULL    
    THEN (CASE WHEN RIGHT(A.SHIFTID, 1) = 1    
         THEN CONCAT(CAST(LEFT(A.SHIFTID, 6) AS DATE), ' 07:15:00.000')    
         ELSE CONCAT(CAST(LEFT(A.SHIFTID, 6) AS DATE), ' 19:15:00.000')    
       END)    
    ELSE B.SHIFTSTARTDATETIME    
     END AS SHIFTSTARTDATETIME,    
     CASE WHEN B.SHIFTENDDATETIME IS NULL    
    THEN (CASE WHEN RIGHT(A.SHIFTID, 1) = 1    
         THEN CONCAT(CAST(LEFT(A.SHIFTID, 6) AS DATE), ' 19:15:00.000')    
         ELSE CONCAT(DATEADD(DAY, 1, CAST(LEFT(A.SHIFTID, 6) AS DATE)), ' 07:15:00.000')    
    END)    
    ELSE B.SHIFTENDDATETIME    
     END AS SHIFTENDDATETIME,    
     COALESCE(B.SHIFTDURATION, 0) [SHIFTDURATION] ,
	B.CrewID,
	B.ShiftStartDate,
	B.ShiftName   
 FROM    
   (SELECT SITEFLAG,    
     'PREV' AS SHIFTFLAG,    
     MAX(PREVSHIFTID) AS SHIFTID    
    FROM [MOR].[SHIFT_INFO] WITH (NOLOCK)    
    GROUP BY SITEFLAG    
    UNION    
    SELECT SITEFLAG,    
     'CURR' AS SHIFTFLAG,    
     MAX(SHIFTID) AS SHIFTID    
    FROM [MOR].[SHIFT_INFO] (NOLOCK)    
    GROUP BY SITEFLAG    
    UNION    
    SELECT SITEFLAG,    
     'NEXT' AS SHIFTFLAG,    
     CASE WHEN (SELECT NEXTSHIFTID    
       FROM (     
           SELECT TOP 1 NEXTSHIFTID,    
            ROW_NUMBER() OVER(PARTITION BY SHIFTID ORDER BY SHIFTID DESC) AS ROW_NUM    
           FROM [MOR].[SHIFT_INFO] (NOLOCK)    
           ORDER BY SHIFTID DESC    
       ) AS NEXTSHIFTID) IS NULL    
       THEN (CASE WHEN RIGHT(MAX(SHIFTID), 1) = 2    
         THEN RIGHT(CONCAT(REPLACE(CAST(DATEADD(DAY, 1, CAST(LEFT(MAX(SHIFTID), 6) AS DATE)) AS VARCHAR(10)), '-', ''), '001'), 9)    
         ELSE RIGHT(CONCAT(REPLACE(CAST(DATEADD(DAY, 1, CAST(LEFT(MAX(SHIFTID), 6) AS DATE)) AS VARCHAR(10)), '-', ''), '002'), 9)    
       END)    
       ELSE MAX(NEXTSHIFTID)    
       END AS SHIFTID    
    FROM [MOR].[SHIFT_INFO] (NOLOCK)    
    GROUP BY SITEFLAG) A    
 LEFT JOIN (    
    SELECT SHIFTID,    
     SHIFTSTARTDATETIME,    
     LEAD(SHIFTSTARTDATETIME) OVER ( ORDER BY SHIFTID) AS SHIFTENDDATETIME,    
     SHIFTDURATION,
	 REPLACE(Crew, 'Crew', '') AS CrewID,
	 FullShiftSuffix AS ShiftName,
	 ShiftStartDate   
    FROM [MOR].[SHIFT_INFO] (NOLOCK)    
 ) B ON A.SHIFTID = B.SHIFTID    
) [S]    
CROSS JOIN TimeZone TZ    
  


