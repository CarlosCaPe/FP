CREATE VIEW [sie].[CONOPS_SIE_EOS_REPORT_V] AS

--SELECT * FROM [sie].[CONOPS_SIE_EOS_REPORT_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [sie].[CONOPS_SIE_EOS_REPORT_V]  
AS  

	SELECT s.SHIFTFLAG
		  ,s.SITEFLAG
		  ,s.[CrewID] as Crew
		  ,FORMAT (s.[ShiftStartDate], 'dd MMM yyyy') as ShiftDate
		  ,s.[ShiftName]
	FROM [sie].CONOPS_SIE_SHIFT_INFO_V s WITH (NOLOCK)

