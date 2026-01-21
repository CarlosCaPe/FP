CREATE VIEW [mor].[CONOPS_MOR_EOS_REPORT_V] AS

--SELECT * FROM [mor].[CONOPS_MOR_EOS_REPORT_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [mor].[CONOPS_MOR_EOS_REPORT_V]  
AS  

	SELECT s.SHIFTFLAG
		  ,s.SITEFLAG
		  ,s.[CrewID] as Crew
		  ,FORMAT (s.[ShiftStartDate], 'dd MMM yyyy') as ShiftDate
		  ,s.[ShiftName]
	FROM [mor].CONOPS_MOR_SHIFT_INFO_V s WITH (NOLOCK)

