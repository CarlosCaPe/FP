CREATE VIEW [TYR].[CONOPS_TYR_TRUCK_TPRH] AS


  
  
  
  
--select * from [tyr].[CONOPS_TYR_TRUCK_TPRH] WITH(NOLOCK)  
CREATE VIEW [TYR].[CONOPS_TYR_TRUCK_TPRH]   
AS  
  
   
 SELECT [th].[ShiftId],  
     [th].[Truck],  
     [th].tonsHaul  
 FROM (  
  SELECT [sd].ShiftId,  
      [sd].[siteflag],  
      [t].FieldId [Truck],  
      COALESCE(SUM([sd].FieldTons), 0) [tonsHaul]  
  FROM [tyr].[shift_dump] [sd] WITH(NOLOCK)  
  LEFT JOIN [tyr].[shift_eqmt] [t] WITH(NOLOCK)  
  ON [sd].FieldTruck = [t].Id  
  GROUP BY [sd].ShiftId, [t].FieldId,[sd].[siteflag]  
 ) [th]  
  
   
   
  
  
  
  

