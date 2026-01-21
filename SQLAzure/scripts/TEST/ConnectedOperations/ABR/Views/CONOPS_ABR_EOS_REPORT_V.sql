CREATE VIEW [ABR].[CONOPS_ABR_EOS_REPORT_V] AS



--SELECT * FROM [abr].[CONOPS_ABR_EOS_REPORT_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [ABR].[CONOPS_ABR_EOS_REPORT_V]  
AS  

	SELECT s.SHIFTFLAG
		  ,s.SITEFLAG
		  ,s.[CrewID] as Crew
		  ,FORMAT (s.[ShiftStartDate], 'dd MMM yyyy') as ShiftDate
		  ,s.[ShiftName]
	FROM [abr].CONOPS_ABR_SHIFT_INFO_V s WITH (NOLOCK)

