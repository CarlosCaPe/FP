CREATE VIEW [cer].[ZZZ_SHIFT_INFO_TEMP] AS


CREATE VIEW [cer].[SHIFT_INFO]  
AS      
    
Select    
site_code as siteflag
,LAG(ShiftId) OVER (ORDER BY ShiftId ASC)  as prevshiftid   
,ShiftId    
,LAG(ShiftId) OVER (ORDER BY ShiftId DESC)  as nextshiftid  
,ShiftName    
,DbName    
,ShiftYear    
,ShiftMonth    
,ShiftDay    
,ShiftSuffix    
,FullShiftSuffix    
,ShiftStartSecSinceMidnight    
,ShiftStartTimestamp    
,ShiftStartTimestampUtc    
,ShiftStartDate    
,ShiftStartDateTime    
,FullShiftName    
,Holiday    
,Crew    
,ShiftDuration    
,ShiftDate    
     
from [cer].[lh2_shift_info_temp] (nolock) --[CERReferenceCache].[APP_DATA].[lh2_shift_info]  (nolocK)

