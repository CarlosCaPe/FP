CREATE VIEW [cer].[CONOPS_CER_EOS_DRILL_NON_UTILIZED_REASON_V] AS


--SELECT * FROM [CER].[CONOPS_CER_EOS_DRILL_NON_UTILIZED_REASON_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [cer].[CONOPS_CER_EOS_DRILL_NON_UTILIZED_REASON_V]  
AS  
  
	SELECT a.SHIFTFLAG
		  ,a.SiteFlag
		  ,'Drill' UnitType
		  ,[stats].Reason
		  ,SUM([stats].duration / 3600.00) AS DurationHours
	FROM [cer].[CONOPS_CER_SHIFT_INFO_V] A (NOLOCK) 
	LEFT JOIN [cer].[CONOPS_CER_DB_EQMT_STATUS_V] [stats] (NOLOCK)
	ON a.SHIFTFLAG = [stats].SHIFTFLAG
	WHERE [stats].status IN ('Demora', 'Reserva')
	GROUP BY a.SHIFTFLAG, a.SiteFlag, [stats].Reason

