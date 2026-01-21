CREATE VIEW [BAG].[CONOPS_BAG_TM_TRAFFIC_CRUSHER_V] AS

  
    
    
    
    
--SELECT * FROM [bag].[CONOPS_BAG_TM_TRAFFIC_CRUSHER_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'      
CREATE VIEW [bag].[CONOPS_BAG_TM_TRAFFIC_CRUSHER_V]      
AS      
    
WITH STOCKPILE AS(
SELECT
	s.shiftflag,
	s.siteflag,
	l.LOC_NAME AS LocationId,
	NULL AS Status,
	'Crusher' AS TrafficType,
	CAST(l.LOC_X AS REAL) [FieldXloc],
	CAST(l.LOC_Y AS REAL) [FieldYloc],
	CAST(l.LOC_Z AS REAL) [FieldZloc] 
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] s WITH (NOLOCK)
LEFT JOIN [BAG].[FLEET_LOCATION_V] l WITH (NOLOCK)
	ON s.siteflag = l.site_code
WHERE l.ISSINK = 1
	AND l.LOC_NAME LIKE '%Crusher%'
)

SELECT 
[c].SHIFTFLAG 
,[c].SITEFLAG
,[c].TrafficType
,[c].LocationID
,[c].Status
,[t].TruckID
,CASE WHEN [t].Location = [c].LocationId
	THEN 1
	ELSE 0
	END AS [IsTruckAtLocation]
,CASE WHEN [c].FieldXloc IS NOT NULL AND [t].FieldXloc IS NOT NULL
	THEN ([c].FieldXloc - [t].FieldXloc)  / 60.0 
	ELSE 0
	END AS dx
,CASE WHEN [c].FieldYloc IS NOT NULL AND [t].FieldYloc IS NOT NULL
	THEN ([c].FieldYloc - [t].FieldYloc) / 60.0  
	ELSE 0
	END AS dy
,CASE WHEN [t].Location IS NOT NULL
	THEN [t].FieldVelocity / 60.0 
	ELSE NULL
	END AS Velocity,
[t].Location AS PushbackId
FROM STOCKPILE [c]
LEFT JOIN [bag].[CONOPS_BAG_TRUCK_DETAIL_V] [t] WITH (NOLOCK)   
ON [c].SHIFTFLAG = [t].shiftflag
	AND [c].SITEFLAG = [t].siteflag
	AND [c].LocationID = [t].Location
    
  

