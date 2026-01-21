CREATE VIEW [TYR].[CONOPS_TYR_EQMT_ALARM_TRUCK_SHOVEL_OPERATOR_BREAK_V] AS



-- SELECT * FROM [tyr].[CONOPS_TYR_EQMT_ALARM_TRUCK_SHOVEL_OPERATOR_BREAK_V] WITH (NOLOCK) WHERE shiftflag = 'CURR'
CREATE VIEW [TYR].[CONOPS_TYR_EQMT_ALARM_TRUCK_SHOVEL_OPERATOR_BREAK_V]
AS

	WITH OperatorBreak AS (
   		SELECT [eq].[SHIFTINDEX],
			   [eq].[SITE_CODE],
			   [REASON],
			   [EQMT],
			   [END_TIME_TS],
			   [DURATION],
			   [OPERID]
   		FROM [tyr].[EQUIPMENT_HOURLY_STATUS] [eq] WITH (NOLOCK)
   		WHERE [REASON] = 400
		      AND [UNIT] IN (1,2)
	),

	OperatorTwoBreak AS (
   		SELECT [SHIFTINDEX],
		       [SITE_CODE],
			   [REASON],
          	   [EQMT] AS EQUIPMENTNUMBER,
			   MAX(END_TIME_TS) AS END_TIME_TS,
          	   SUM([DURATION]) AS STATUS_DURATION,
          	   [OPERID],
          	   COUNT([OPERID]) cn,
			   1 AS Priority
   		FROM [OperatorBreak]
   		GROUP BY [SHIFTINDEX], [SITE_CODE], [REASON], [EQMT], [OPERID]
	),

	OperatorBreakExceed AS (
   		SELECT [SHIFTINDEX],
		       [SITE_CODE],
			   [REASON],
          	   [EQMT] AS EQUIPMENTNUMBER,
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
			   MAX(END_TIME_TS) AS END_TIME_TS,
			   SUM([DURATION]) AS STATUS_DURATION,
          	   [OPERID],
			   3 AS Priority
   		FROM [OperatorBreak]
   		GROUP BY [SHIFTINDEX], [SITE_CODE], [REASON], [EQMT], [OPERID]
	)

	SELECT shiftflag,
		   siteflag,
		   [s].[NAME] AS [AlertType],
		   CONCAT([s].[NAME], ' - ', [o].[REASON]) AS [AlertName],
		   EQUIPMENTNUMBER,
		   END_TIME_TS,
		   STATUS_DURATION,
		   [OPERID] AS OPERATORID,
		   CASE WHEN [OPERID] IS NULL OR [OPERID] = -1 THEN NULL
				ELSE concat([img].[value],
					 RIGHT('0000000000' + [o].[OPERID], 10),'.jpg') END as OperatorImageURL,
		   [w].FIRST_LAST_NAME AS OperatorName,
		   Priority,
		   ROW_NUMBER() OVER (PARTITION BY shiftflag, EQUIPMENTNUMBER, [o].[OPERID]
                                 	  ORDER BY Priority ASC) num
	FROM [tyr].[CONOPS_TYR_SHIFT_INFO_V] a (NOLOCK)
	LEFT JOIN (
 		SELECT [SHIFTINDEX], [SITE_CODE], [REASON], EQUIPMENTNUMBER, END_TIME_TS,
			   CONVERT(varchar, DATEADD(ss, STATUS_DURATION, 0), 108) AS STATUS_DURATION,
			   [OPERID], Priority
		FROM OperatorTwoBreak
		WHERE cn > 2
		UNION ALL
		SELECT [SHIFTINDEX], [SITE_CODE], [REASON], EQUIPMENTNUMBER, END_TIME_TS,
			   CONVERT(varchar, DATEADD(ss, STATUS_DURATION, 0), 108) AS STATUS_DURATION, 
			   [OPERID], Priority
		FROM OperatorBreakExceed
		UNION ALL
		SELECT [SHIFTINDEX], [SITE_CODE], [REASON], EQUIPMENTNUMBER, END_TIME_TS,
			   CONVERT(varchar, DATEADD(ss, STATUS_DURATION, 0), 108) AS STATUS_DURATION, 
			   [OPERID], Priority
		FROM OperatorBreakTotalExceed
		WHERE STATUS_DURATION >= 1800
	) [o]
	ON a.SHIFTINDEX = o.SHIFTINDEX AND a.SITEFLAG = o.SITE_CODE
	LEFT JOIN [dbo].[operator_personnel_map] [w] WITH (NOLOCK)
	ON CAST([w].[OPERATOR_ID] AS numeric) = [o].[OPERID] AND [w].SHIFTINDEX = [o].SHIFTINDEX
	   AND [o].SITE_CODE = [w].SITE_CODE
	LEFT JOIN [DBO].[LH_REASON] [S] WITH (NOLOCK)  
	ON [S].[SHIFTINDEX] = [o].[SHIFTINDEX] AND [S].[SITE_CODE] = [o].SITE_CODE  
	   AND [S].[REASON] = [o].REASON
	LEFT JOIN [dbo].[LOOKUPS] img WITH (NOLOCK)
	ON img.TableCode = 'IMGURL'


