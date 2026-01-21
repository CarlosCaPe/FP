CREATE VIEW [SAF].[CONOPS_SAF_EOS_DRILL_NON_UTILIZED_REASON_V] AS




--SELECT * FROM [saf].[CONOPS_SAF_EOS_DRILL_NON_UTILIZED_REASON_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [saf].[CONOPS_SAF_EOS_DRILL_NON_UTILIZED_REASON_V]  
AS  
  
	SELECT a.SHIFTFLAG
		  ,a.SiteFlag
		  ,'Drill' UnitType
		  ,[stats].Reason
		  ,SUM([stats].duration / 3600.00) AS DurationHours
	FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] A (NOLOCK) 
	LEFT JOIN [saf].[CONOPS_SAF_DB_EQMT_STATUS_V] [stats] (NOLOCK)
	ON a.SHIFTFLAG = [stats].SHIFTFLAG
	WHERE [stats].status IN ('Delay', 'Spare')
	GROUP BY a.SHIFTFLAG, a.SiteFlag, [stats].Reason



