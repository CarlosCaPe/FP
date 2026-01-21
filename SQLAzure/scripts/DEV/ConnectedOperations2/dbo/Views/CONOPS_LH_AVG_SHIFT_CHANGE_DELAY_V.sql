CREATE VIEW [dbo].[CONOPS_LH_AVG_SHIFT_CHANGE_DELAY_V] AS


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



