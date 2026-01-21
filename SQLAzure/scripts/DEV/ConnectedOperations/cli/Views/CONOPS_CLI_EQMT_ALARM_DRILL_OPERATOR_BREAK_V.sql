CREATE VIEW [cli].[CONOPS_CLI_EQMT_ALARM_DRILL_OPERATOR_BREAK_V] AS


-- SELECT * FROM [cli].[CONOPS_CLI_EQMT_ALARM_DRILL_OPERATOR_BREAK_V] WITH (NOLOCK) WHERE shiftflag = 'CURR'
CREATE VIEW [cli].[CONOPS_CLI_EQMT_ALARM_DRILL_OPERATOR_BREAK_V]
AS

	WITH OperatorDetail AS (
   		SELECT shiftflag,
          	   siteflag,
			   [SHIFTINDEX],
          	   DRILL_ID,
          	   OPERATORID,
          	   OperatorName
      	   FROM (
          	   SELECT a.shiftflag,
					  a.siteflag,
					  [ds].SHIFTINDEX,
					  REPLACE(DRILL_ID, ' ','') AS DRILL_ID,
					  OPERATORID,
					  [w].FIRST_LAST_NAME AS OperatorName,
					  ROW_NUMBER() OVER (PARTITION BY [ds].SHIFTINDEX, [ds].SITE_CODE, Drill_ID
                                 		 ORDER BY END_HOLE_TS DESC) num
          	   FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] a (NOLOCK)
          	   LEFT JOIN [dbo].[FR_DRILLING_SCORES] [ds] WITH (NOLOCK)
          	   ON [a].ShiftIndex = [ds].SHIFTINDEX
				  AND [a].siteflag = 'CMX' AND ds.SITE_CODE = 'CLI'
       		   LEFT JOIN [dbo].[operator_personnel_map] [w] WITH (NOLOCK)
       		   ON CAST([w].[OPERATOR_ID] AS numeric) = [ds].OperatorID_Num AND [w].SHIFTINDEX = [ds].SHIFTINDEX
          	   AND [ds].SITE_CODE = [w].SITE_CODE
          	   WHERE DRILL_ID IS NOT NULL AND [ds].[SITE_CODE] = 'CLI'
      	   ) [ds]
   		WHERE num = 1
	),

	OperatorBreak AS (
   		SELECT shiftflag,
		       siteflag,
			   [d].[SHIFTINDEX],
			   [MACHINESTATUSCODE],
          	   EQUIPMENTNUMBER,
			   END_TIME_TS,
          	   STATUS_DURATION,
          	   OPERATORID,
          	   OperatorName
   		FROM [cli].[DRILL_UTILIZATION] [D] WITH (NOLOCK)
   		LEFT JOIN OperatorDetail [o]
   		ON [o].SHIFTINDEX = [d].SHIFTINDEX AND [o].DRILL_ID = [d].EQUIPMENTNUMBER
   		WHERE [MACHINESTATUSCODE] = 400
	),

	OperatorTwoBreak AS (
   		SELECT shiftflag,
		       siteflag,
			   [SHIFTINDEX],
			   [MACHINESTATUSCODE],
          	   EQUIPMENTNUMBER,
			   MAX(END_TIME_TS) AS END_TIME_TS,
          	   SUM(STATUS_DURATION) AS STATUS_DURATION,
          	   OPERATORID,
          	   OperatorName,
          	   COUNT(OPERATORID) cn,
			   1 AS Priority
   		FROM [OperatorBreak]
   		GROUP BY shiftflag, siteflag, [SHIFTINDEX], [MACHINESTATUSCODE], EQUIPMENTNUMBER, OPERATORID, OperatorName
	),

	OperatorBreakExceed AS (
   		SELECT shiftflag,
		       siteflag,
			   [SHIFTINDEX],
			   [MACHINESTATUSCODE],
          	   EQUIPMENTNUMBER,
			   END_TIME_TS,
			   STATUS_DURATION,
          	   OPERATORID,
          	   OperatorName,
			   2 AS Priority
   		FROM [OperatorBreak]
   		WHERE STATUS_DURATION > 1200
	),

	OperatorBreakTotalExceed AS (
   		SELECT shiftflag,
		       siteflag,
			   [SHIFTINDEX],
			   [MACHINESTATUSCODE],
          	   EQUIPMENTNUMBER,
			   MAX(END_TIME_TS) AS END_TIME_TS,
			   SUM(STATUS_DURATION) AS STATUS_DURATION,
          	   OPERATORID,
          	   OperatorName,
			   3 AS Priority
   		FROM [OperatorBreak]
   		GROUP BY shiftflag, siteflag, [SHIFTINDEX], [MACHINESTATUSCODE], EQUIPMENTNUMBER, OPERATORID, OperatorName
	)

	SELECT shiftflag,
		   siteflag,
		   [s].[NAME] AS [AlertType],
		   CONCAT([s].[NAME], ' - ', [o].MACHINESTATUSCODE) AS [AlertName],
		   EQUIPMENTNUMBER,
		   END_TIME_TS,
		   STATUS_DURATION,
		   OPERATORID,
		   CASE WHEN [OperatorId] IS NULL OR [OperatorId] = -1 THEN NULL
				ELSE concat('https://images.services.fmi.com/publishedimages/',
					 RIGHT('0000000000' + [o].OPERATORID, 10),'.jpg') END as OperatorImageURL,
		   OperatorName,
		   Priority,
		   ROW_NUMBER() OVER (PARTITION BY shiftflag, EQUIPMENTNUMBER, OPERATORID
                                 	  ORDER BY Priority ASC) num
	FROM (
 		SELECT shiftflag, siteflag, [SHIFTINDEX], [MACHINESTATUSCODE], EQUIPMENTNUMBER, END_TIME_TS,
			   CONVERT(varchar, DATEADD(ss, STATUS_DURATION, 0), 108) AS STATUS_DURATION,
			   OPERATORID, OperatorName, Priority
		FROM OperatorTwoBreak
		WHERE cn > 2
		UNION AL