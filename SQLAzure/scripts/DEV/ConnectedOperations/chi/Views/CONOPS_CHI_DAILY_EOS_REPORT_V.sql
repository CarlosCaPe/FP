CREATE VIEW [chi].[CONOPS_CHI_DAILY_EOS_REPORT_V] AS
  
  
--SELECT * FROM [chi].[CONOPS_CHI_DAILY_EOS_REPORT_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'    
CREATE VIEW [chi].[CONOPS_CHI_DAILY_EOS_REPORT_V]    
AS    
  
 SELECT s.SHIFTFLAG  
    ,s.SITEFLAG  
    ,s.[CrewID] as Crew  
    ,FORMAT (CAST(s.ShiftStartDateTime AS DATE), 'dd MMM yyyy') as ShiftDate   
    ,s.[ShiftName]  
 FROM [chi].CONOPS_CHI_EOS_SHIFT_INFO_V s WITH (NOLOCK)  
  
  
