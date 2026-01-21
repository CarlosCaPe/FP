CREATE VIEW [cer].[CONOPS_CER_EOS_REPORT_V] AS

--SELECT * FROM [cer].[CONOPS_CER_EOS_REPORT_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [cer].[CONOPS_CER_EOS_REPORT_V]  
AS  

	SELECT s.SHIFTFLAG
		  ,s.SITEFLAG
		  ,s.[CrewID] as Crew
		  ,FORMAT (s.[ShiftStartDate], 'dd MMM yyyy') as ShiftDate
		  ,s.[ShiftName]
	FROM [cer].CONOPS_CER_SHIFT_INFO_V s WITH (NOLOCK)

