CREATE VIEW [CHI].[CONOPS_CHI_EQMT_SHIFT_INFO_V] AS





--select * from [chi].[CONOPS_CHI_EQMT_SHIFT_INFO_V] order by shiftflag
CREATE VIEW [chi].[CONOPS_CHI_EQMT_SHIFT_INFO_V] 
AS

SELECT sh.siteflag,
       sh.shiftflag,
       sh.shiftid,
       (CONVERT(int, (DATEDIFF(DD, '7/12/2007', CAST(sh.ShiftStartDateTime AS DATE))*2) + 27412 +
                    (SELECT RIGHT(sh.[ShiftId], 1) - 1))) ShiftIndex,
       sh.ShiftStartDateTime,
       sh.ShiftEndDateTime
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
            END AS ShiftEndDateTime
     FROM
         (SELECT siteflag,
                 'CURR' AS shiftflag,
                 max(prevshiftid) AS shiftid
          FROM [chi].[shift_info] WITH (NOLOCK)
		  GROUP BY siteflag
          UNION SELECT siteflag,
                       'CURR' AS shiftflag,
                       max(shiftid) AS shiftid
          FROM [chi].[shift_info] WITH (NOLOCK)
		  GROUP BY siteflag
          UNION SELECT siteflag,
                       'PREV' AS shiftflag,
                       max(prevshiftid) AS shiftid
          FROM [chi].[shift_info] WITH (NOLOCK)
		  GROUP BY siteflag
          UNION SELECT siteflag,
                       'PREV' AS shiftflag,
                       CASE
                           WHEN RIGHT(max(prevshiftid), 1) = 2 THEN CONCAT(LEFT(max(prevshiftid), 8), '1')
                           ELSE CONCAT(RIGHT(CONVERT(VARCHAR(8), DATEADD(DAY, -1, CONVERT(DATETIME, CONCAT('20', LEFT(max(prevshiftid), 6)), 112)), 112), 6), '002')
                       END AS shiftid
          FROM [chi].[shift_info] WITH (NOLOCK)
		  GROUP BY siteflag
          UNION SELECT siteflag,
                       'NEXT' AS shiftflag,
                       max(shiftid) AS shiftid
          FROM [chi].[shift_info] WITH (NOLOCK)
		  GROUP BY siteflag
          UNION SELECT siteflag,
                       'NEXT' AS shiftflag,
                       CASE WHEN (SELECT nextshiftid
                                  FROM (
									SELECT TOP 1 nextshiftid,
                                           ROW_NUMBER() OVER(PARTITION BY shiftid ORDER BY shiftid DESC) AS row_num
                                    FROM [chi].[shift_info] WITH (NOLOCK)
                                    ORDER BY shiftid DESC) AS nextshiftid) IS NULL
							THEN (CASE WHEN RIGHT(max(shiftid), 1) = 2
									   THEN right(concat(replace(cast(dateadd(DAY, 1, cast(LEFT(max(shiftid), 6) AS date)) AS varchar(10)), '-', ''), '001'), 9)
                                       ELSE right(concat(replace(cast(dateadd(DAY, 1, cast(LEFT(max(shiftid), 6) AS date)) AS varchar(10)), '-', ''), '002'), 9)
                                  END)
                            ELSE max(nextshiftid)
                       END AS shiftid
          FROM [chi].[shift_info] WITH (NOLOCK)
		  GROUP BY siteflag) a
     LEFT JOIN
         (SELECT shiftid,
                 ShiftStartDateTime,
                 LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid) AS ShiftEndDateTime,
                 ShiftDuration
          FROM [chi].[shift_info] WITH (nolock)) b ON a.shiftid = b.shiftid) sh


