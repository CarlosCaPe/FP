CREATE VIEW [TYR].[CONOPS_TYR_EOS_REPORT_V] AS


--SELECT * FROM [tyr].[CONOPS_TYR_EOS_REPORT_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [tyr].[CONOPS_TYR_EOS_REPORT_V]  
AS  

	SELECT s.SHIFTFLAG
		  ,s.SITEFLAG
		  ,s.[CrewID] as Crew
		  ,FORMAT (s.[ShiftStartDate], 'dd MMM yyyy') as ShiftDate
		  ,s.[ShiftName]
	FROM [tyr].CONOPS_TYR_SHIFT_INFO_V s WITH (NOLOCK)

