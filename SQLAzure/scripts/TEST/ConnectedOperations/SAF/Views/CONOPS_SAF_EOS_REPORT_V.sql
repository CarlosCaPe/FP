CREATE VIEW [SAF].[CONOPS_SAF_EOS_REPORT_V] AS


--SELECT * FROM [saf].[CONOPS_SAF_EOS_REPORT_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [saf].[CONOPS_SAF_EOS_REPORT_V]  
AS  

	SELECT s.SHIFTFLAG
		  ,s.SITEFLAG
		  ,s.[CrewID] as Crew
		  ,FORMAT (s.[ShiftStartDate], 'dd MMM yyyy') as ShiftDate
		  ,s.[ShiftName]
	FROM [saf].CONOPS_SAF_SHIFT_INFO_V s WITH (NOLOCK)


