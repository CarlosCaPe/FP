CREATE VIEW [cli].[asset_efficiency_v] AS


--SELECT * FROM CLI.ASSET_EFFICIENCY_V
CREATE VIEW [cli].[asset_efficiency_v]   
AS      

WITH EqType AS(
SELECT DISTINCT 
	EQMTID,
	EQMTTYPE
FROM dbo.lh_equip_list WITH(NOLOCK)
WHERE SITE_CODE = 'CLI'
),

EqmtHist AS (
    SELECT [ShiftDate],
           SHIFT_CODE,
		   SITE_CODE,
           SHIFTINDEX,
           EQMT,
           [HOS].UNIT,
           START_TIME_TS,
           END_TIME_TS,
           DURATION,
           [hos].STATUS,
           REASON,
           CATEGORY,
           COMMENTS,
           CASE WHEN LAG(EQMT, 1, 0) OVER ( ORDER BY Shiftindex, EQMT, START_TIME_TS ) IS NULL
                THEN 1
                ELSE CASE WHEN EQMT <> LAG(EQMT, 1, 0) OVER ( ORDER BY Shiftindex, EQMT, START_TIME_TS )
                           OR REASON <> LAG(REASON, 1, 0) OVER ( ORDER BY Shiftindex, EQMT, START_TIME_TS )
                           OR [Status] <> LAG([Status], 1, 0) OVER ( ORDER BY Shiftindex, EQMT, START_TIME_TS )
                     THEN 1
                     ELSE CASE WHEN EQMT <> LEAD(EQMT, 1, 0) OVER ( ORDER BY Shiftindex, EQMT, START_TIME_TS )
                                     OR REASON <> LEAD(REASON, 1, 0) OVER ( ORDER BY Shiftindex, EQMT, START_TIME_TS )
                                     OR [Status] <> LEAD([Status], 1, 0) OVER ( ORDER BY Shiftindex, EQMT, START_TIME_TS )
                                THEN 2
                                ELSE 0
                          END
                    END
              END AS [StatusIndex]
    FROM [cli].[EQUIPMENT_HOURLY_STATUS] [HOS] WITH (NOLOCK)
    WHERE [HOS].UNIT IN (1,2,12,13,14,15,18,19,20,21,23,24,25)
), 

HOS AS ( 
    SELECT [ShiftDate],
           SHIFT_CODE,
		   SHIFTINDEX,
		   SITE_CODE,
           EQMT,
           UNIT,
           START_TIME_TS,
           CASE WHEN EQMT = LEAD(EQMT, 1, 0) OVER ( ORDER BY SHIFTINDEX, EQMT, START_TIME_TS )
                     AND REASON = LEAD(REASON, 1, 0) OVER ( ORDER BY SHIFTINDEX, EQMT, START_TIME_TS )
                     AND STATUS = LEAD(STATUS, 1, 0) OVER ( ORDER BY SHIFTINDEX, EQMT, START_TIME_TS )
					 AND 2 = LEAD(StatusIndex, 1, 0) OVER ( ORDER BY SHIFTINDEX, EQMT, START_TIME_TS )
                THEN LEAD(END_TIME_TS, 1, 0) OVER ( ORDER BY SHIFTINDEX, EQMT, START_TIME_TS )
                ELSE CASE WHEN 1 = LEAD(StatusIndex, 1, 0) OVER ( ORDER BY SHIFTINDEX, EQMT, START_TIME_TS )
							   AND StatusIndex = 1
						  THEN END_TIME_TS
						  ELSE NULL
					 END
           END AS END_TIME_TS,
           CASE WHEN EQMT = LEAD(EQMT, 1, 0) OVER ( ORDER BY SHIFTINDEX, EQMT, START_TIME_TS )
                     AND REASON = LEAD(REASON, 1, 0) OVER ( ORDER BY SHIFTINDEX, EQMT, START_TIME_TS )
                     AND STATUS = LEAD(STATUS, 1, 0) OVER ( ORDER BY SHIFTINDEX, EQMT, START_TIME_TS )
					 AND 2 = LEAD(StatusIndex, 1, 0) OVER ( ORDER BY SHIFTINDEX, EQMT, START_TIME_TS )
                THEN LEAD(DURATION, 1, 0) OVER ( ORDER BY SHIFTINDEX, EQMT, START_TIME_TS )
                 ELSE CASE WHEN 1 = LEAD(StatusIndex, 1, 0) OVER ( ORDER BY SHIFTINDEX, EQMT, START_TIME_TS )
							   AND StatusIndex = 1
						  THEN DURATION
						  ELSE NULL
					 END
           END AS DURATION,
           STATUS,
           REASON,
           CATEGORY,
           COMMENTS
    FROM EqmtHist eh
    WHERE StatusIndex != 0
),

Final AS(
	SELECT Right([Year], 2) + FORMAT(CAST([Month] AS numeric), '00') +
			FORMAT(CAST([Day] AS numeric), '00') + FORMAT(CAST(SHIFT_CODE AS numeric), '000') [ShiftId],
		   EQMT,
		   NULL [FieldEqmttype],
		   [et].EQMTTYPE [eqmttype],
		   [UnitType],
		   START_TIME_TS [StartDateTime],
		   END_TIME_TS [EndDateTime],
		   [Duration],
		   STATUS [StatusIdx],
		   [StatusDesc] [Status],
		   CATEGORY [CategoryIdx],
		   [CategoryDesc] [Category],
		   REASON [reasonidx],
		   [ReasonDesc] [reasons],
		   COMMENTS
	FROM (

		SELECT REVERSE(PARSENAME(REPLACE(REVERSE([Shif