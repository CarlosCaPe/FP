CREATE VIEW [Arch].[SHIFT_INFO_V] AS


  
  
  
  
  
  
--select * from [dbo].[SHIFT_INFO_V]    
    
CREATE   VIEW [Arch].[SHIFT_INFO_V]    
AS    
    
SELECT     
siteflag,    
shiftflag,    
shiftid,    
(CONVERT(int, (DATEDIFF(DD, '7/12/2007', CAST(ShiftStartDateTime as DATE))*2) + 27412 + (SELECT RIGHT([ShiftId],1) - 1))) ShiftIndex,    
ShiftStartDateTime,    
ShiftEndDateTime,    
ShiftDuration    
FROM [Arch].[CONOPS_ARCH_SHIFT_INFO_V] (NOLOCK)    
    
