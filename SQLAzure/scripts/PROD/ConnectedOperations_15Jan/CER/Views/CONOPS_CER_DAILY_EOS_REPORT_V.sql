CREATE VIEW [CER].[CONOPS_CER_DAILY_EOS_REPORT_V] AS
  
  
--SELECT * FROM [cer].[CONOPS_CER_DAILY_EOS_REPORT_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'    
CREATE VIEW [cer].[CONOPS_CER_DAILY_EOS_REPORT_V]    
AS    
  
 SELECT s.SHIFTFLAG  
    ,s.SITEFLAG  
    ,s.[CrewID] as Crew  
    ,FORMAT (CAST(s.ShiftStartDateTime AS DATE), 'dd MMM yyyy') as ShiftDate  
    ,s.[ShiftName]  
 FROM [cer].CONOPS_CER_EOS_SHIFT_INFO_V s WITH (NOLOCK)  
  
  
