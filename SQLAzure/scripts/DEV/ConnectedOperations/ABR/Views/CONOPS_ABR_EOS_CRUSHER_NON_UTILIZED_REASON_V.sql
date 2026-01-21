CREATE VIEW [ABR].[CONOPS_ABR_EOS_CRUSHER_NON_UTILIZED_REASON_V] AS



--SELECT * FROM [abr].[CONOPS_ABR_EOS_CRUSHER_NON_UTILIZED_REASON_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [abr].[CONOPS_ABR_EOS_CRUSHER_NON_UTILIZED_REASON_V]  
AS  
  
	SELECT a.SHIFTFLAG
		  ,a.SiteFlag
		  ,'Crusher' UnitType
		  --,se.status AS Status
		  --,se.reason AS DelayReasonCode
		  ,rt.name AS Reason
		  ,SUM(se.duration / 3600) AS DurationHours
	FROM [abr].[CONOPS_ABR_SHIFT_INFO_V] A (NOLOCK) 
	LEFT JOIN [dbo].[status_event] se WITH (NOLOCK)
	ON a.SHIFTINDEX = se.shiftindex 
	LEFT JOIN [dbo].[lh_reason] rt WITH (NOLOCK)
	ON se.shiftindex = rt.shiftindex AND rt.SITE_CODE = 'ELA'
	   AND se.status = rt.status AND se.reason = rt.reason
	WHERE se.site_code = 'ELA'
	AND se.unit = 17 AND se.status IN (1, 3, 4)
	AND rt.name IS NOT NULL
	GROUP BY a.SHIFTFLAG, a.SiteFlag, rt.name

