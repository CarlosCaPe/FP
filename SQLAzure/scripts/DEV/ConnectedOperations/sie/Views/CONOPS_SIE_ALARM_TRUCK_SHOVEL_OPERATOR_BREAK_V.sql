CREATE VIEW [sie].[CONOPS_SIE_ALARM_TRUCK_SHOVEL_OPERATOR_BREAK_V] AS

-- SELECT * FROM [sie].[CONOPS_SIE_ALARM_TRUCK_SHOVEL_OPERATOR_BREAK_V] WITH (NOLOCK) WHERE shiftflag = 'CURR'
CREATE VIEW [sie].[CONOPS_SIE_ALARM_TRUCK_SHOVEL_OPERATOR_BREAK_V]
AS

	WITH OperatorBreak AS (
   		SELECT [eq].[SHIFTINDEX],
			   [eq].[SITE_CODE],
			   [REASON],
			   [EQMT],
			   [END_TIME_TS],
			   [DURATION],
			   [OPERID],
			   [UNIT]
   		FROM [sie].[EQUIPMENT_HOURLY_STATUS] [eq] WITH (NOLOCK)
   		WHERE [REASON] = 400
		      AND [UNIT] IN (1,2)
	),

	OperatorTwoBreak AS (
   		SELECT [SHIFTINDEX],
		       [SITE_CODE],
			   [REASON],
          	   [EQMT] AS EQUIPMENTNUMBER,
			   [UNIT],
			   MAX(END_TIME_TS) AS END_TIME_TS,
          	   SUM([DURATION]) AS STATUS_DURATION,
          	   [OPERID],
          	   COUNT([OPERID]) cn,
			   1 AS Priority
   		FROM [OperatorBreak]
   		GROUP BY [SHIFTINDEX], [SITE_CODE], [REASON], [EQMT], [OPERID], [UNIT]
	),

	OperatorBreakExceed AS (
   		SELECT [SHIFTINDEX],
		       [SITE_CODE],
			   [REASON],
          	   [EQMT] AS EQUIPMENTNUMBER,
			   [UNIT],
			   END_TIME_TS,
			   [DURATION] AS STATUS_DURATION,
          	   [OPERID],
			   2 AS Priority
   		FROM [OperatorBreak]
   		WHERE [DURATION] > 1200
	),

	OperatorBreakTotalExceed AS (
   		SELECT [SHIFTINDEX],
		       [SITE_CODE],
			   [REASON],
          	   [EQMT] AS EQUIPMENTNUMBER,
			   [UNIT],
			   MAX(END_TIME_TS) AS END_TIME_TS,
			   SUM([DURATION]) AS STATUS_DURATION,
          	   [OPERID],
			   3 AS Priority
   		FROM [OperatorBreak]
   		GROUP BY [SHIFTINDEX], [SITE_CODE], [REASON], [EQMT], [OPERID], [UNIT]
	),

	OperatorBreakAlert AS (
		SELECT [o].[SITE_CODE],
			   [o].SHIFTINDEX,
			   [s].[NAME] AS [AlertType],
			   CONCAT([s].[NAME], ' - ', [o].[REASON]) AS [AlertName],
			   '' AS AlertDesciption,
			   EQUIPMENTNUMBER,
			   [UNIT], 
			   [OPERID],
			   END_TIME_TS,
			   STATUS_DURATION,
			   GETUTCDATE() AS GeneratedDate,
			   Priority,
			   ROW_NUMBER() OVER (PARTITION BY [o].shiftindex, EQUIPMENTNUMBER, [OPERID]
                                 		  ORDER BY Priority ASC) num
		FROM (
 			SELECT [SITE_CODE], [SHIFTINDEX], [REASON], EQUIPMENTNUMBER, [UNIT], END_TIME_TS,
				   CONVERT(varchar, DATEADD(ss, STATUS_DURATION, 0), 108) AS STATUS_DURATION,
				   [OPERID], Priority
			FROM OperatorTwoBreak
			WHERE cn > 2
			UNION ALL
			SELECT [SITE_CODE], [SHIFTINDEX], [REASON], EQUIPMENTNUMBER, [UNIT], END_TIME_TS,
				   CONVERT(varchar, DATEADD(ss, STATUS_DURATION, 0), 108) AS STATUS_DURATION, 
				   [OPERID], Priority
			FROM OperatorBreakExceed
			UNION ALL
			SELECT [SITE_CODE], [SHIFTINDEX], [REASON], EQUIPMENTNUMBER, [UNIT], END_TIME_TS,
				   CONVERT(varchar, DATEADD(ss, STATUS_DURATION, 0), 108) AS STATUS_DURATION, 
				   [OPERID], Priority
			FROM OperatorBreakTotalExceed
			WHERE STATUS_DURATION >= 1800
		) [o]
		LEFT JOIN [DBO].[LH_REASON] [S] WITH (NOLOCK)  
		ON [S].[SHIFTINDEX] = [o].[SHIFTINDEX] AND [S].[SITE_CODE] = [o].[SITE_CODE]  
		   AND [S].[REASON] = [o].[REASON]
	)

	SELECT SHIFTINDEX,
		   [SITE_CODE] as siteflag,
		   [AlertType],
		   [AlertName],
		   CASE Priority
				WHEN 1 THEN 'Operator takes more than 2 breaks in a shift.'
				WHEN 2 THEN 'Operator break exceeds 20 minutes.'
				WHEN 3 THEN 'Operator total breaks exceed 30 mintes.'
		   END AS AlertDesciption,
		   CASE [UNIT]
				WHEN 1 THEN 'Truck'
				WHEN 2 THEN 'Shovel'
		   END AS EqmtType,
		   EQUIPMENTNUMBER,
		   [OPERID] AS [OPERATORID],
		   END_TIME_TS,
		   STATUS_DURATION,
		   GeneratedDate
	FROM OperatorBreakAlert
	WHERE num = 1

