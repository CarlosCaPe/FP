CREATE VIEW [TYR].[CONOPS_TYR_CM_DISPATCH_SUMMARY_V] AS





-- SELECT * FROM [tyr].[CONOPS_TYR_CM_DISPATCH_SUMMARY_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'PREV'  
CREATE VIEW [TYR].[CONOPS_TYR_CM_DISPATCH_SUMMARY_V]  
AS  


SELECT 
SHIFTFLAG
,[SHIFTINDEX]
,SITEFLAG
,NULL [HOS]
,NULL [Hr]
,CAST(NULL AS VARCHAR(10)) [CrusherLoc]
,NULL [AvgTimeAtCrusher]
,NULL [AvgIntraArrivalTime]
,NULL [AvgTrafficIntensity]
,0 NrofLoad
,NULL [AvgMinIdle]
,NULL [AvgDumpTime]
,0 [Tons]
,0 NrofDump
FROM [tyr].[CONOPS_TYR_SHIFT_INFO_V]




