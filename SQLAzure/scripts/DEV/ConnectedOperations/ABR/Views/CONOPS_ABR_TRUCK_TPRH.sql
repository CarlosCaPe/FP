CREATE VIEW [ABR].[CONOPS_ABR_TRUCK_TPRH] AS
  
  
  
  
--select * from [abr].[CONOPS_ABR_TRUCK_TPRH] WITH(NOLOCK)  
CREATE VIEW [abr].[CONOPS_ABR_TRUCK_TPRH]   
AS  
  
   
 SELECT [th].[ShiftId],  
     [th].[Truck],  
     [th].tonsHaul  
 FROM (  
  SELECT [sd].ShiftId,  
      [sd].[siteflag],  
      [t].FieldId [Truck],  
      COALESCE(SUM([sd].FieldTons), 0) [tonsHaul]  
  FROM [abr].[shift_dump] [sd] WITH(NOLOCK)  
  LEFT JOIN [abr].[shift_eqmt] [t] WITH(NOLOCK)  
  ON [sd].FieldTruck = [t].Id  
  GROUP BY [sd].ShiftId, [t].FieldId,[sd].[siteflag]  
 ) [th]  
  
   
   
  
  
  
  
