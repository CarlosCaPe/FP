CREATE VIEW [CER].[SHIFT_INFO] AS




CREATE VIEW [cer].[SHIFT_INFO]  
AS      
    
Select    
'CER' as siteflag
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
from [CERReferenceCache].[APP_DATA].[lh2_shift_info] WITH(NOLOCK)
WHERE SHIFTID >= CONCAT(CONVERT(VARCHAR(8), DATEADD(DAY, - 2,GETDATE()), 12), '001')


