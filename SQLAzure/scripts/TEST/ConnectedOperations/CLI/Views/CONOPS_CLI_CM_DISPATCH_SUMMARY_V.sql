CREATE VIEW [CLI].[CONOPS_CLI_CM_DISPATCH_SUMMARY_V] AS




-- SELECT * FROM [cli].[CONOPS_CLI_CM_DISPATCH_SUMMARY_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [cli].[CONOPS_CLI_CM_DISPATCH_SUMMARY_V]  
AS  

	WITH CrLocShift AS (
   		SELECT a.SHIFTINDEX,
          	   a.SHIFTFLAG,
			   a.SITEFLAG,
			   'CRUSHER 1' AS CrusherLoc,
			   a.SHIFTSTARTDATETIME
   		FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] a WITH (NOLOCK)
	),

	MaxArrive AS (
		SELECT [CALCULATED_SHIFTINDEX] [SHIFTINDEX]
			  ,[SITE_CODE]
			  ,MAX([TIMEARRIVE]) [MAXTIMEARRIVE]
		FROM [dbo].[LH_DUMP] WITH (NOLOCK)
		WHERE [SITE_CODE] = 'CLI'
			  AND LOC = 'CRUSHER 1'
		GROUP BY [CALCULATED_SHIFTINDEX], [SITE_CODE]
	),

	RawDump AS (
		SELECT [CALCULATED_SHIFTINDEX] [SHIFTINDEX]
			  ,d.[SITE_CODE]
			  ,[HOS]
			  ,[LOC]
			  ,TRUCK
			  ,[DUMPTONS] [Tons]
			  ,([TIMEDUMP] -  [TIMEARRIVE])/60 AS IdleTIme
			  ,([TIMEEMPTY] - [TIMEDUMP])/60 AS DumpTime
			  ,([TIMEEMPTY]- [TIMEARRIVE])/60 AS ServiceTime
			  ,IIF(ma.MAXTIMEARRIVE > [TIMEARRIVE], (ma.MAXTIMEARRIVE - [TIMEARRIVE]) / 60, 0) AS IntraArrivalTime
		FROM [dbo].[LH_DUMP] d WITH (NOLOCK)
		LEFT JOIN MaxArrive ma
		ON d.SITE_CODE = ma.SITE_CODE AND d.[CALCULATED_SHIFTINDEX] = ma.SHIFTINDEX
		WHERE d.[SITE_CODE] = 'CLI'
			  AND LOC = 'CRUSHER 1'
	),

	NrOfLoad AS (
		SELECT  shiftindex,
				site_code,
				HOS,
				DUMPASN AS CrusherLoc,
				count(excav) as NrofLoad 
		FROM dbo.lh_load WITH (nolock)
		WHERE site_code = 'CLI' AND DUMPASN = 'CRUSHER 1'
		GROUP BY shiftindex, site_code, HOS, DUMPASN
	),

	DumpData AS (
		SELECT [SHIFTINDEX]
			  ,[SITE_CODE]
			  ,[HOS]
			  ,[LOC]
			  ,COUNT(TRUCK) NrofDump
			  ,SUM([Tons]) [Tons]
			  ,AVG(ServiceTime) ServiceTime
			  ,AVG(IntraArrivalTime) IntraArrivalTime
			  ,IIF(AVG(ServiceTime) > 0 AND AVG(IntraArrivalTime) > 0, (1 / AVG(IntraArrivalTime)) / ((1 / AVG(ServiceTime)) * 2) * 100, 0) TrafficIntensity
			  ,AVG(IdleTIme) IdleTIme
			  ,AVG(DumpTime) DumpTime
		FROM RawDump
		GROUP BY [SHIFTINDEX], [SITE_CODE], [HOS], [LOC]
	)

	SELECT cl.SHIFTFLAG
		  ,d.[SHIFTINDEX]
		  ,cl.SITEFLAG
		  ,d.[HOS] + 1 [HOS]
		  ,DATEADD(HOUR, d.[HOS], cl.SHIFTSTARTDATETIME) [Hr]
		  ,d.[LOC] [CrusherLoc]
		  ,ServiceTime [AvgTimeAtCrusher]
		  ,IntraArrivalTime [AvgIntraArrivalTime]
		  ,TrafficIntensity [AvgTrafficIntensity]
		  ,nl.NrofLoad
		  ,IdleTIme [AvgMinIdle]
		  ,DumpTime [AvgDumpTime]
		  ,[Tons]
		  ,NrofDump
	FROM CrLocShift cl
	LEFT JOIN DumpData d
	ON cl.SHIFTINDEX = d.SHIFTINDEX
		AND cl.CrusherLoc= d.[LOC]
	LEFT JOIN NrOfLoad nl
	ON d.SHIFTINDEX = nl.SHIFTINDEX 
		AND d.HOS = nl.HOS 
	   AND d.LOC = nl.CrusherLoc
	WHERE d.SHIFTINDEX IS NOT NULL



