CREATE VIEW [cli].[CONOPS_CLI_ALARM_DRILL_OPERATOR_BREAK_V] AS


-- SELECT * FROM [cli].[CONOPS_CLI_ALARM_DRILL_OPERATOR_BREAK_V] WITH (NOLOCK) WHERE shiftflag = 'CURR'
CREATE VIEW [cli].[CONOPS_CLI_ALARM_DRILL_OPERATOR_BREAK_V]
AS

	WITH OperatorDetail AS (
   		SELECT 'CMX' AS siteflag,
			   [SHIFTINDEX],
          	   DRILL_ID,
          	   OPERATORID
      	   FROM (
          	   SELECT ds.SITE_CODE AS siteflag,
					  [ds].SHIFTINDEX,
					  LEFT(REPLACE(DRILL_ID, ' ',''), 2) + RIGHT('00' + RIGHT(REPLACE(DRILL_ID, ' ',''), 1), 2) AS DRILL_ID,
					  [w].OPERATOR_ID OPERATORID,
					  ROW_NUMBER() OVER (PARTITION BY [ds].SHIFTINDEX, [ds].SITE_CODE, Drill_ID
                                 		 ORDER BY END_HOLE_TS DESC) num
          	   FROM [dbo].[FR_DRILLING_SCORES] [ds] WITH (NOLOCK)
			   LEFT JOIN [dbo].[operator_personnel_map] [w] WITH (NOLOCK)
				    ON UPPER([ds].OPERATORNAME) = CONCAT([w].LAST_NAME, ' ', [w].FIRST_NAME) AND [w].SHIFTINDEX = [ds].SHIFTINDEX
					   AND [ds].SITE_CODE = [w].SITE_CODE
          	   WHERE DRILL_ID IS NOT NULL AND [ds].[SITE_CODE] = 'CLI'
      	   ) [ds]
   		WHERE num = 1
	),

	OperatorBreak AS (
   		SELECT siteflag,
			   [d].[SHIFTINDEX],
			   [MACHINESTATUSCODE],
          	   EQUIPMENTNUMBER,
			   END_TIME_TS,
          	   STATUS_DURATION,
          	   OPERATORID
   		FROM [cli].[DRILL_UTILIZATION] [D] WITH (NOLOCK)
   		LEFT JOIN OperatorDetail [o]
   		ON [o].SHIFTINDEX = [d].SHIFTINDEX AND [o].DRILL_ID = [d].EQUIPMENTNUMBER
   		WHERE [MACHINESTATUSCODE] = 400
	),

	OperatorTwoBreak AS (
   		SELECT siteflag,
			   [SHIFTINDEX],
			   [MACHINESTATUSCODE],
          	   EQUIPMENTNUMBER,
			   MAX(END_TIME_TS) AS END_TIME_TS,
          	   SUM(STATUS_DURATION) AS STATUS_DURATION,
          	   OPERATORID,
          	   COUNT(OPERATORID) cn,
			   1 AS Priority
   		FROM [OperatorBreak]
   		GROUP BY siteflag, [SHIFTINDEX], [MACHINESTATUSCODE], EQUIPMENTNUMBER, OPERATORID
	),

	OperatorBreakExceed AS (
   		SELECT siteflag,
			   [SHIFTINDEX],
			   [MACHINESTATUSCODE],
          	   EQUIPMENTNUMBER,
			   END_TIME_TS,
			   STATUS_DURATION,
          	   OPERATORID,
			   2 AS Priority
   		FROM [OperatorBreak]
   		WHERE STATUS_DURATION > 1200
	),

	OperatorBreakTotalExceed AS (
   		SELECT siteflag,
			   [SHIFTINDEX],
			   [MACHINESTATUSCODE],
          	   EQUIPMENTNUMBER,
			   MAX(END_TIME_TS) AS END_TIME_TS,
			   SUM(STATUS_DURATION) AS STATUS_DURATION,
          	   OPERATORID,
			   3 AS Priority
   		FROM [OperatorBreak]
   		GROUP BY siteflag, [SHIFTINDEX], [MACHINESTATUSCODE], EQUIPMENTNUMBER, OPERATORID
	),

	OperatorBreakAlert AS (
		SELECT siteflag,
			   [o].SHIFTINDEX,
			   [s].[NAME] AS [AlertType],
			   CONCAT([s].[NAME], ' - ', [o].MACHINESTATUSCODE) AS [AlertName],
			   '' AS AlertDesciption,
			   EQUIPMENTNUMBER,
			   OPERATORID,
			   END_TIME_TS,
			   STATUS_DURATION,
			   GETUTCDATE() AS GeneratedDate,
			   Priority,
			   ROW_NUMBER() OVER (PARTITION BY [o].shiftindex, EQUIPMENTNUMBER, OPERATORID
                                 		  ORDER BY Priority ASC) num
		FROM (
 			SELECT siteflag, [SHIFTINDEX], [MACHINESTATUSCODE], EQUIPMENTNUMBER, END_TIME_TS,
				   CONVERT(varchar, DATEADD(ss, STATUS_DURATION, 0), 108) AS STATUS_DURATION,
				   OPERATORID, Priority
			FROM OperatorTwoBreak
			WHERE cn > 2
			UNION ALL
			SELECT siteflag, [SHIFTINDEX], [MACHINESTATUSCODE], EQUIPMENTNUMBER, END_TIME_TS,
				   CONVERT(varchar, DATEADD(ss, STATUS_DURATION, 0), 108) AS STATUS_DURATION, 
				   OPERATORID, Priority
			FROM OperatorBreakExceed
			UNION ALL
			SELECT siteflag, [SHIFTINDEX], [MACHINESTATUSCODE], EQUIPMENTNUMBER, END_TIME_TS,
				   CONVERT(varchar, DATEADD(ss, STATUS_DURATION, 0), 108) AS STATUS_DURATION, 
				   OPERATORID, Priority
			FROM OperatorBreakTotalExceed
			WHERE STATUS_DURATION >= 1800
		) [o]
		LEFT JOIN [DBO].[LH_REASON] [S] WITH (NOLOCK)  
		ON [S].[SHIFTINDEX] = [