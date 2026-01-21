CREATE VIEW [TYR].[CONOPS_TYR_TM_TRAFFIC_SHOVEL_V] AS


--SELECT * FROM [tyr].[CONOPS_TYR_TM_TRAFFIC_SHOVEL_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'        
CREATE VIEW [TYR].[CONOPS_TYR_TM_TRAFFIC_SHOVEL_V]        
AS        
      
 WITH CurrStats AS (      
  SELECT shiftid      
      , eqmt      
      , StatusIdx      
      , Status      
      , reasonidx      
      , reasons      
      , duration      
  FROM (      
   SELECT shiftid,      
       eqmt,      
       [StatusIdx],      
       [Status],      
       reasonidx,      
       reasons,      
       duration/60.0 AS duration,      
       ROW_NUMBER() OVER (PARTITION BY shiftid, eqmt  ORDER BY startdatetime DESC) AS rn      
   FROM [tyr].[asset_efficiency] WITH (NOLOCK)      
   WHERE UnitType = 'Shovel'      
  ) [a]      
  WHERE rn = 1      
 ),      
      
 Shovel AS (      
  SELECT [shift].SHIFTFLAG      
     ,[shift].SITEFLAG      
     ,[s].FieldId AS LocationID      
     ,[loc].[FieldId] AS [Location]      
     ,[cs].Status      
     ,'Shovel' AS TrafficType      
     ,[s].FieldXloc      
     ,[s].FieldYloc      
     ,[s].FieldZ      
  FROM [tyr].[CONOPS_TYR_SHIFT_INFO_V] [shift] WITH (NOLOCK)      
  LEFT JOIN [tyr].[pit_excav_c] [s] WITH (NOLOCK)      
  ON [shift].SHIFTINDEX = [s].SHIFTINDEX      
  LEFT JOIN [tyr].[pit_loc] [loc] WITH (NOLOCK)      
  ON [loc].Id = [s].FieldLoc      
  LEFT JOIN CurrStats [cs]       
  ON [s].shiftid = [cs].shiftid AND [s].FieldId = [cs].eqmt      
  --WHERE [s].FieldId LIKE 'S%'      
 )      
      
 SELECT [s].SHIFTFLAG       
    ,[s].SITEFLAG      
    ,[s].TrafficType      
    ,[s].LocationID      
    ,[s].Status      
    ,[t].TruckID      
    ,CASE WHEN [t].Location IS NOT NULL AND [t].Location = [t].Destination      
    THEN 1      
    ELSE 0      
     END AS [IsTruckAtLocation]      
    ,CASE WHEN [s].FieldXloc IS NOT NULL AND [t].FieldXloc IS NOT NULL      
    THEN ([s].FieldXloc - [t].FieldXloc)/60.0      
    ELSE 0      
     END AS dx      
    ,CASE WHEN [s].FieldYloc IS NOT NULL AND [t].FieldYloc IS NOT NULL      
    THEN ([s].FieldYloc - [t].FieldYloc)/60.0      
    ELSE 0      
     END AS dy      
    ,CASE WHEN [t].Location IS NOT NULL AND [t].Location = [t].Destination      
    THEN NULL      
    ELSE [t].FieldVelocity / 60.0       
     END AS Velocity,
	 [t].Destination AS PushbackId
 FROM Shovel [s]      
 LEFT JOIN [tyr].[CONOPS_TYR_TRUCK_DETAIL_V] [t] WITH (NOLOCK)      
 ON [s].SHIFTFLAG = [t].shiftflag AND [s].SITEFLAG = [t].siteflag      
    AND [s].Location = [t].Destination      
      
      
    
  
