CREATE VIEW [BAG].[CONOPS_BAG_EOS_REPORT_V] AS



--SELECT * FROM [bag].[CONOPS_BAG_EOS_REPORT_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [bag].[CONOPS_BAG_EOS_REPORT_V]  
AS  

	SELECT s.SHIFTFLAG
		  ,s.SITEFLAG
		  ,s.[CrewID] as Crew
		  ,FORMAT (s.[ShiftStartDate], 'dd MMM yyyy') as ShiftDate
		  ,s.[ShiftName]
	FROM [bag].CONOPS_BAG_SHIFT_INFO_V s WITH (NOLOCK)



