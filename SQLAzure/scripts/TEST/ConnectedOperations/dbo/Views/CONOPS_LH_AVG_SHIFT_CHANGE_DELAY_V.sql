CREATE VIEW [dbo].[CONOPS_LH_AVG_SHIFT_CHANGE_DELAY_V] AS







--select * from [dbo].[CONOPS_LH_AVG_SHIFT_CHANGE_DELAY_V] where shiftflag = 'curr'
CREATE VIEW [dbo].[CONOPS_LH_AVG_SHIFT_CHANGE_DELAY_V]
AS

SELECT shiftflag,
	   siteflag,
	   avgduration [Actual],
	   15 [Target]
FROM [mor].[CONOPS_MOR_AVG_SHIFT_CHANGE_DELAY_V]  WITH (NOLOCK)
WHERE siteflag = 'MOR'

UNION ALL

SELECT shiftflag,
	   siteflag,
	   avgduration [Actual],
	   15 [Target]
FROM [bag].[CONOPS_BAG_AVG_SHIFT_CHANGE_DELAY_V]  WITH (NOLOCK)
WHERE siteflag = 'BAG'

UNION ALL

SELECT shiftflag,
	   siteflag,
	   avgduration [Actual],
	   15 [Target]
FROM [saf].[CONOPS_SAF_AVG_SHIFT_CHANGE_DELAY_V]  WITH (NOLOCK)
WHERE siteflag = 'SAF'



UNION ALL

SELECT shiftflag,
	   siteflag,
	   avgduration [Actual],
	   15 [Target]
FROM [sie].[CONOPS_SIE_AVG_SHIFT_CHANGE_DELAY_V]  WITH (NOLOCK)
WHERE siteflag = 'SIE'

UNION ALL

SELECT shiftflag,
	   siteflag,
	   avgduration [Actual],
	   15 [Target]
FROM [cli].[CONOPS_CLI_AVG_SHIFT_CHANGE_DELAY_V]  WITH (NOLOCK)
WHERE siteflag = 'CMX'

UNION ALL

SELECT shiftflag,
	   siteflag,
	   avgduration [Actual],
	   15 [Target]
FROM [chi].[CONOPS_CHI_AVG_SHIFT_CHANGE_DELAY_V]  WITH (NOLOCK)
WHERE siteflag = 'CHI'

UNION ALL

SELECT shiftflag,
	   siteflag,
	   avgduration [Actual],
	   15 [Target]
FROM [cer].[CONOPS_CER_AVG_SHIFT_CHANGE_DELAY_V]  WITH (NOLOCK)
WHERE siteflag = 'CER'

