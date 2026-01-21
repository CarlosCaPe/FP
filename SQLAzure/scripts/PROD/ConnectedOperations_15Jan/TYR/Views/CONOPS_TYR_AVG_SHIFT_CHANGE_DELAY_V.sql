CREATE VIEW [TYR].[CONOPS_TYR_AVG_SHIFT_CHANGE_DELAY_V] AS


  
  
--select * from [tyr].[CONOPS_TYR_AVG_SHIFT_CHANGE_DELAY_V] WITH (NOLOCK)  
CREATE VIEW [TYR].[CONOPS_TYR_AVG_SHIFT_CHANGE_DELAY_V]  
AS  
  
SELECT [shift].shiftflag,  
    [shift].siteflag,  
    avgduration [Actual],  
    15 [Target]  
FROM [tyr].[CONOPS_TYR_SHIFT_INFO_V] [shift] WITH (NOLOCK)  
LEFT JOIN (  
 select site_code,  
     shiftindex,  
     CAST(coalesce(avg(duration)/60, 0) AS DECIMAL(2,0)) as avgduration  
 from dbo.status_event WITH (NOLOCK)
 where site_code = 'TYR'  
   and status = 4  
   and reason = 439  
   and unit = 1  
 group by site_code, shiftindex  
) [AvgShiftDelay]  
on [AvgShiftDelay].SHIFTINDEX = [shift].ShiftIndex  
   AND [AvgShiftDelay].site_code = [shift].siteflag  

  
  
  

