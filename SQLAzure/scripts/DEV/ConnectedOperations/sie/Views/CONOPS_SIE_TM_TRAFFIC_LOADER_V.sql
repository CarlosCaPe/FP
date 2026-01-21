CREATE VIEW [sie].[CONOPS_SIE_TM_TRAFFIC_LOADER_V] AS
  
    
    
    
    
--SELECT * FROM [sie].[CONOPS_SIE_TM_TRAFFIC_LOADER_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'      
CREATE VIEW [sie].[CONOPS_SIE_TM_TRAFFIC_LOADER_V]      
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
   FROM [sie].[asset_efficiency] WITH (NOLOCK)    
   WHERE UnitType = 'Shovel'    
  ) [a]    
  WHERE rn = 1    
 ),    
    
 Loader AS (    
  SELECT [shift].SHIFTFLAG    
     ,[shift].SITEFLAG    
     ,[s].FieldId AS LocationID    
     ,[loc].[FieldId] AS [Location]    
     ,[cs].Status    
     ,'Loader' AS TrafficType    
     ,[s].FieldXloc    
     ,[s].FieldYloc    
     ,[s].FieldZ    
  FROM [sie].[CONOPS_SIE_SHIFT_INFO_V] [shift] WITH (NOLOCK)    
  LEFT JOIN [sie].[pit_excav_c] [s] WITH (NOLOCK)    
  ON [shift].SHIFTINDEX = [s].SHIFTINDEX    
  LEFT JOIN [sie].[pit_loc] [loc] WITH (NOLOCK)    
  ON [loc].Id = [s].FieldLoc    
  LEFT JOIN CurrStats [cs]     
  ON [s].shiftid = [cs].shiftid AND [s].FieldId = [cs].eqmt    
  WHERE [s].FieldId LIKE 'L%'    
 )    
    
 SELECT [l].SHIFTFLAG     
    ,[l].SITEFLAG    
    ,[l].TrafficType    
    ,[l].LocationID    
    ,[l].Status    
    ,[t].TruckID    
    ,CASE WHEN [t].Location IS NOT NULL AND [t].Location = [t].Destination    
    THEN 1    
    ELSE 0    
     END AS [IsTruckAtLocation]    
    ,CASE WHEN [l].FieldXloc IS NOT NULL AND [t].FieldXloc IS NOT NULL    
    THEN ([l].FieldXloc - [t].FieldXloc)  / 60.0     
    ELSE 0    
     END AS dx    
    ,CASE WHEN [l].FieldYloc IS NOT NULL AND [t].FieldYloc IS NOT NULL    
    THEN ([l].FieldYloc - [t].FieldYloc)  / 60.0     
    ELSE 0    
     END AS dy    
    ,CASE WHEN [t].Location IS NOT NULL AND [t].Location = [t].Destination    
    THEN NULL    
    ELSE [t].FieldVelocity / 60.0     
     END AS Velocity,
	 [t].Destination AS PushbackId
 FROM Loader [l]    
 LEFT JOIN [sie].[CONOPS_SIE_TRUCK_DETAIL_V] [t] WITH (NOLOCK)    
 ON [l].SHIFTFLAG = [t].shiftflag AND [l].SITEFLAG = [t].siteflag    
    AND [l].Location = [t].Destination    
    
    
  
