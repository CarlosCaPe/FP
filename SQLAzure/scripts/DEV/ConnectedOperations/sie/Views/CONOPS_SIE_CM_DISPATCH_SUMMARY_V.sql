CREATE VIEW [sie].[CONOPS_SIE_CM_DISPATCH_SUMMARY_V] AS





-- SELECT * FROM [sie].[CONOPS_SIE_CM_DISPATCH_SUMMARY_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'PREV'  
CREATE VIEW [sie].[CONOPS_SIE_CM_DISPATCH_SUMMARY_V]  
AS  

	WITH CrLoc AS (
   		SELECT 'CR13909O' CrusherLoc
   		UNION ALL
   		SELECT 'A-SIDE' CrusherLoc
   		UNION ALL
   		SELECT 'B-SIDE' CrusherLoc
	),

	CrLocShift AS (
   		SELECT a.SHIFTINDEX,
          	   a.SHIFTFLAG,
			   a.SITEFLAG,
			   a.SHIFTSTARTDATETIME,
			   CrusherLoc
   		FROM CrLoc, [sie].[CONOPS_SIE_SHIFT_INFO_V] a WITH (NOLOCK)
	),

	MaxArrive AS (
		SELECT [CALCULATED_SHIFTINDEX] [SHIFTINDEX]
			  ,[SITE_CODE]
			  ,LOC
			  ,MAX([TIMEARRIVE]) [MAXTIMEARRIVE]
		FROM [dbo].[LH_DUMP] WITH (NOLOCK)
		WHERE [SITE_CODE] = 'SIE'
			  AND LOC IN (SELECT CrusherLoc FROM CrLoc)
		GROUP BY [CALCULATED_SHIFTINDEX], [SITE_CODE], LOC
	),

	RawDump AS (
		SELECT [CALCULATED_SHIFTINDEX] [SHIFTINDEX]
			  ,d.[SITE_CODE]
			  ,[HOS]
			  ,d.[LOC]
			  ,TRUCK
			  ,[DUMPTONS] [Tons]
			  ,([TIMEDUMP] -  [TIMEARRIVE])/60 AS IdleTIme
			  ,([TIMEEMPTY] - [TIMEDUMP])/60 AS DumpTime
			  ,([TIMEEMPTY]- [TIMEARRIVE])/60 AS ServiceTime
			  ,IIF(ma.MAXTIMEARRIVE > [TIMEARRIVE], (ma.MAXTIMEARRIVE - [TIMEARRIVE]) / 60, 0) AS IntraArrivalTime
		FROM [dbo].[LH_DUMP] d WITH (NOLOCK)
		LEFT JOIN MaxArrive ma
		ON d.SITE_CODE = ma.SITE_CODE AND d.[CALCULATED_SHIFTINDEX] = ma.SHIFTINDEX
		   AND d.LOC = ma.LOC
		WHERE d.[SITE_CODE] = 'SIE'
			  AND d.LOC IN (SELECT CrusherLoc FROM CrLoc)
	),

	NrOfLoad AS (
		SELECT  shiftindex,
				site_code,
				HOS,
				DUMPASN AS CrusherLoc,
				count(excav) as NrofLoad 
		FROM dbo.lh_load WITH (nolock)
		WHERE site_code = 'SIE' AND DUMPASN IN (SELECT CrusherLoc FROM CrLoc)
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



