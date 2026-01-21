CREATE VIEW [BAG].[CONOPS_BAG_DAILY_EOS_REPORT_V] AS
  
  
--SELECT * FROM [bag].[CONOPS_BAG_DAILY_EOS_REPORT_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'    
CREATE VIEW [bag].[CONOPS_BAG_DAILY_EOS_REPORT_V]    
AS    
  
 SELECT s.SHIFTFLAG  
    ,s.SITEFLAG  
    ,s.[CrewID] as Crew  
    ,FORMAT (CAST(s.ShiftStartDateTime AS DATE), 'dd MMM yyyy') as ShiftDate  
    ,s.[ShiftName]  
 FROM [bag].CONOPS_BAG_EOS_SHIFT_INFO_V s WITH (NOLOCK)  
  
  
