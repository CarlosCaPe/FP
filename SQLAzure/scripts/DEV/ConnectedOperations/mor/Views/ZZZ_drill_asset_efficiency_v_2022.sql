CREATE VIEW [mor].[ZZZ_drill_asset_efficiency_v_2022] AS





--SELECT * FROM [mor].[drill_asset_efficiency_v] WITH (NOLOCK)
CREATE   VIEW [mor].[drill_asset_efficiency_v_2022]   
AS      

	WITH EqmtHist AS (
		SELECT [d].[SHIFT_DATE]
			  ,[d].[SITE_CODE]
			  ,[d].[SHIFTINDEX]
			  ,REPLACE([d].[EQUIPMENTNUMBER], ' ','') AS DRILL_ID
			  ,[d].[EQUIPMENTMODEL]
			  ,[d].[START_TIME_TS]
			  ,[d].[END_TIME_TS]
			  ,[d].[STATUS_DURATION] AS DURATION
			  ,[s].[STATUS]
			  ,[d].[MACHINESTATUSCODE] AS REASONIDX
			  ,[s].[NAME] AS REASON
			  ,[s].[CATEGORY]
			  ,CASE WHEN LAG([EQUIPMENTNUMBER], 1, 0) OVER SIEQSTT IS NULL
            		THEN 1
            		ELSE CASE WHEN [EQUIPMENTNUMBER] <> LAG([EQUIPMENTNUMBER], 1, 0) OVER SIEQSTT
                          		   OR [d].[MACHINESTATUSCODE] <> LAG([d].[MACHINESTATUSCODE], 1, 0) OVER SIEQSTT
                          		   OR [s].[STATUS] <> LAG([s].[STATUS], 1, 0) OVER SIEQSTT
                    		  THEN 1
                    		  ELSE CASE WHEN [EQUIPMENTNUMBER] <> LEAD([EQUIPMENTNUMBER], 1, 0) OVER SIEQSTT
                                    		 OR [d].[MACHINESTATUSCODE] <> LEAD([d].[MACHINESTATUSCODE], 1, 0) OVER SIEQSTT
                                    		 OR [s].[STATUS] <> LEAD([s].[STATUS], 1, 0) OVER SIEQSTT
                               			THEN 2
                               			ELSE 0
                         		  END
                   			END
        		END AS [StatusIndex]
		FROM	[mor].[DRILL_UTILIZATION] [d] WITH (NOLOCK)
		LEFT JOIN 
				[dbo].[LH_REASON] [s] WITH (NOLOCK)
			ON 
				[s].[SHIFTINDEX] = [d].[SHIFTINDEX] 
			AND 
				[s].[SITE_CODE] = [d].[SITE_CODE]
			AND 
				[s].[REASON] = [d].[MACHINESTATUSCODE]
		WINDOW	SIEQSTT AS (
							ORDER BY [d].[SHIFTINDEX], [EQUIPMENTNUMBER], [d].[START_TIME_TS]
							)

	),	
	HOS AS ( 
   		SELECT [SHIFT_DATE],
			   SHIFTINDEX,
			   SITE_CODE,
          	   DRILL_ID,
			   [EQUIPMENTMODEL],
          	   START_TIME_TS,
          	   CASE WHEN DRILL_ID = LEAD(DRILL_ID, 1, 0) OVER			SIDISTT
                     	 AND REASONIDX = LEAD(REASONIDX, 1, 0) OVER		SIDISTT
                     	 AND STATUS = LEAD(STATUS, 1, 0) OVER			SIDISTT
						 AND 2 = LEAD(StatusIndex, 1, 0) OVER			SIDISTT
                	THEN LEAD(END_TIME_TS, 1, 0) OVER					SIDISTT
                	ELSE CASE WHEN 1 = LEAD(StatusIndex, 1, 0) OVER		SIDISTT
								   AND StatusIndex = 1
							  THEN END_TIME_TS
							  ELSE NULL
						 END
           	   END AS END_TIME_TS,
          	   CASE WHEN DRILL_ID = LEAD(DRILL_ID, 1, 0) OVER			SIDISTT
                     	 AND REASONIDX = LEAD(REASONIDX, 1, 0) OVER		SIDISTT
                     	 AND STATUS = LEAD(STATUS, 1, 0) OVER			SIDISTT
						 AND 2 = LEAD(StatusIndex, 1, 0) OVER			SIDISTT
                	THEN LEAD(DURATION, 1, 0) OVER						SIDISTT
                 	 ELSE CASE WHEN 1 = LEAD(StatusIndex, 1, 0) OVER	SIDISTT
								   AND StatusIndex = 1
							  THEN DURATION
							  ELSE NULL
						 END
           	   END AS DURATION,
          	   STATUS,
			   REASONIDX,
          	   REASON,
          	   CATEGORY
   		FROM EqmtHist eh
   		WHERE StatusIndex != 0
		WINDOW	SIDISTT AS (
							ORDER BY [SHIFTINDEX], [DRILL_ID], [START_TIME_TS]
							)
	)

	SELECT SHIFTINDEX,
		   SITE_CODE,
		   DRILL_ID,
		   [EQUIPMENTMODEL] AS MODEL,
		   START_TIME_TS [StartDateTime],
		   END_TIME_TS [EndDateTime],
		   [Duration],
		   STATUS [StatusIdx],
		   [StatusDesc] [Status],
		   CATEGORY [CategoryIdx],
		   [CategoryDesc] [Category],
		   [reasonidx],
		   [reason]
	FROM (

		SELECT SHIFTINDEX,
			   HOS.SITE_CODE,
			   DRILL_ID,
			   [EQUIPMENTMODEL],
			   START_TIME_TS,
			   END_TIME_TS,
			   DATEDIFF(MILLISECOND, START_TIME_TS, LAG(START_TIME_TS, 1, END_TIME_TS) OVER pAIoSIDISTT) / 1000 AS DURATION,
			   HOS.STATUS,
			   [statsType].Description [StatusDesc],
			   REASONIDX,
			   REASON,
			   CATEGORY,
			   [categoryType].Des