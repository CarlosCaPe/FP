CREATE VIEW [chi].[CONOPS_CHI_TM_TRAFFIC_CRUSHER_V] AS
  
    
    
    
    
--SELECT * FROM [chi].[CONOPS_CHI_TM_TRAFFIC_CRUSHER_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'      
CREATE VIEW [chi].[CONOPS_CHI_TM_TRAFFIC_CRUSHER_V]      
AS      
    
 WITH CRUSHER AS (    
  SELECT [shift].SHIFTFLAG    
     ,[shift].SITEFLAG    
     ,loc.[FieldId] [LocationID]    
     ,e.DESCRIPTION [Status]    
     ,'Crusher' [TrafficType]    
     ,CAST(loc.[FieldYloc] AS REAL) [FieldYloc]    
     ,CAST(loc.[FieldXloc] AS REAL) [FieldXloc]    
     ,CAST(loc.[FieldZloc] AS REAL) [FieldZloc]    
  FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] [shift] WITH (NOLOCK)     
  LEFT JOIN [chi].[PIT_LOC_C] loc WITH (NOLOCK)    
  ON [shift].SHIFTINDEX = [loc].SHIFTINDEX    
  INNER JOIN [chi].[PIT_AUXEQMT_C] aux WITH (NOLOCK)    
  ON loc.[FieldId] = 'CRUSHER' AND aux.[FieldId] = 'CRUSH-AUX-N'    
     AND loc.SHIFTINDEX = aux.SHIFTINDEX AND loc.siteflag = aux.siteflag    
  LEFT JOIN [dbo].[LH_REASON] rp WITH (NOLOCK)    
  ON rp.REASON = loc.[FieldReason]    
     AND rp.SITE_CODE = loc.siteflag AND rp.SHIFTINDEX = loc.SHIFTINDEX    
  LEFT JOIN [chi].ENUM e WITH (NOLOCK)    
  ON rp.STATUS = e.IDX AND e.ENUMTYPEID = 1    
 )    
    
 SELECT [c].SHIFTFLAG     
    ,[c].SITEFLAG    
    ,[c].TrafficType    
    ,[c].LocationID    
    ,[c].Status    
    ,[t].TruckID    
    ,CASE WHEN [t].Location IS NOT NULL AND [t].Location = [t].Destination    
    THEN 1    
    ELSE 0    
     END AS [IsTruckAtLocation]    
    ,CASE WHEN [c].FieldXloc IS NOT NULL AND [t].FieldXloc IS NOT NULL    
    THEN ([c].FieldXloc - [t].FieldXloc)  / 60.0     
    ELSE 0    
     END AS dx    
    ,CASE WHEN [c].FieldYloc IS NOT NULL AND [t].FieldYloc IS NOT NULL    
    THEN ([c].FieldYloc - [t].FieldYloc)  / 60.0     
    ELSE 0    
     END AS dy    
    ,CASE WHEN [t].Location IS NOT NULL AND [t].Location = [t].Destination    
    THEN NULL    
    ELSE [t].FieldVelocity / 60.0     
     END AS Velocity ,
	 [t].Destination AS PushbackId
 FROM CRUSHER [c]    
 LEFT JOIN [chi].[CONOPS_CHI_TRUCK_DETAIL_V] [t] WITH (NOLOCK)    
 ON [c].SHIFTFLAG = [t].shiftflag AND [c].SITEFLAG = [t].siteflag    
    AND [c].LocationID = [t].Destination    
    
    
  
