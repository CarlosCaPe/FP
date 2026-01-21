CREATE VIEW [MOR].[CONOPS_MOR_CM_DISPATCH_SUMMARY_V] AS

-- SELECT * FROM [mor].[CONOPS_MOR_CM_DISPATCH_SUMMARY_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'PREV'  
CREATE VIEW [mor].[CONOPS_MOR_CM_DISPATCH_SUMMARY_V]  
AS  

WITH CrLoc AS (
   	SELECT 'Crusher 2' CrusherLoc
   	UNION ALL
   	SELECT 'Crusher 3' CrusherLoc
),

CrLocShift AS (
   	SELECT a.SHIFTINDEX,
		 	   a.SHIFTFLAG,
		   a.SITEFLAG,
		   a.SHIFTSTARTDATETIME,
		   CrusherLoc
   	FROM CrLoc, [mor].[CONOPS_MOR_SHIFT_INFO_V] a WITH (NOLOCK)
),

MaxArrive AS (
	SELECT 
		SHIFTINDEX
		,SITEFLAG
		,LOC
		,MAX(FieldTimeArrive) MAXTIMEARRIVE
	FROM (
		SELECT 
			SHIFTINDEX
			,SITEFLAG
			,LOC
			,FieldTimeArrive
		FROM MOR.SHIFT_DUMP_DETAIL_V WITH (NOLOCK)
		WHERE LOC IN ('C2MIL','C2MFL','849-MFL', 'C3MIL','C3MFL','859-MILL')
	) m
	GROUP BY SHIFTINDEX, SITEFLAG, LOC
),

RawDump AS (
	SELECT 
		d.SHIFTINDEX
		,d.SiteFlag AS SITE_CODE
		,DUMPTIME_HOS AS HOS
		,d.LOC
		,TRUCK
		,FieldLSizeTons AS Tons
		,(FieldTimeDump -  FieldTimeArrive)/60 AS IdleTIme
		,(FieldTimeEmpty - FieldTimeDump)/60 AS DumpTime
		,(FieldTimeEmpty- FieldTimeArrive)/60 AS ServiceTime
		,IIF(ma.MAXTimeArrive > FieldTimeArrive, (ma.MAXTimeArrive - FieldTimeArrive) / 60, 0) AS IntraArrivalTime
	FROM MOR.SHIFT_DUMP_DETAIL_V d WITH (NOLOCK)
	LEFT JOIN MaxArrive ma
	ON d.SiteFlag = ma.SITEFLAG AND d.SHIFTINDEX = ma.SHIFTINDEX AND d.LOC = ma.LOC
	WHERE d.LOC IN ('C2MIL','C2MFL','849-MFL', 'C3MIL','C3MFL','859-MILL')
),

NrOfLoad AS (
	SELECT shiftindex
		  ,siteflag
		  ,HOS
		  ,CrusherLoc
		  ,count(excav) as NrofLoad 
	FROM (
		SELECT  shiftindex,
				siteflag,
				TimeFull_HOS AS HOS,
				CASE WHEN Loc IN ('C2MIL', 'C2MFL', '849-MFL') THEN 'Crusher 2'
					WHEN Loc IN ('C3MIL', 'C3MIL', '859-MILL') THEN 'Crusher 3'
				END CrusherLoc,
				excav
		FROM MOR.SHIFT_LOAD_DETAIL_V WITH (nolock)
		WHERE Loc IN ('C2MIL','C2MFL','849-MFL', 'C3MIL','C3MFL','859-MILL')
	) m
	GROUP BY shiftindex, siteflag, HOS, CrusherLoc
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
		  ,CASE WHEN AVG(ServiceTime) > 0 AND AVG(IntraArrivalTime) > 0 
			THEN (1.0 / NULLIF(AVG(IntraArrivalTime), 0)) / ((1.0 / NULLIF(AVG(ServiceTime), 0)) * 2) * 100
			ELSE 0
			END AS TrafficIntensity
		  ,AVG(IdleTIme) IdleTIme
		  ,AVG(DumpTime) DumpTime
	FROM (
		SELECT SHIFTINDEX
			  ,SITE_CODE
			  ,HOS
			  ,CASE WHEN LOC IN ('C2MIL', 'C2MFL', '849-MFL') THEN 'Crusher 2'
					WHEN LOC IN ('C3MIL', 'C3MIL', '859-MILL') THEN 'Crusher 3'
			   END LOC
			  ,TRUCK
			  ,Tons
			  ,ServiceTime
			  ,IntraArrivalTime
			  ,IdleTIme
			  ,DumpTime
		FROM RawDump
	) m
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


