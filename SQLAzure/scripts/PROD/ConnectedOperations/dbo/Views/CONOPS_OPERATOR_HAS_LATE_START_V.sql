CREATE VIEW [dbo].[CONOPS_OPERATOR_HAS_LATE_START_V] AS


CREATE VIEW [dbo].[CONOPS_OPERATOR_HAS_LATE_START_V]
AS

SELECT shiftflag,
	   siteflag,
	   shiftindex,
	   eqmtid,
	   unit_code,
	   OperatorName,
	   CASE WHEN [OperatorId] IS NULL OR [OperatorId] = -1 THEN NULL
	   ELSE concat('https://images.services.fmi.com/publishedimages/',[OperatorId],'.jpg') END as OperatorImageURL,
	   [FirstLoginDateTime],
	   ShiftStartDateTime,
	   FirstLoginTime,
	   [FirstLoad]
FROM [mor].[CONOPS_MOR_OPERATOR_HAS_LATE_START_V] WITH (NOLOCK)
WHERE siteflag = 'MOR'

UNION ALL

SELECT shiftflag,
	   siteflag,
	   shiftindex,
	   eqmtid,
	   unit_code,
	   OperatorName,
	   CASE WHEN [OperatorId] IS NULL OR [OperatorId] = -1 THEN NULL
	   ELSE concat('https://images.services.fmi.com/publishedimages/',[OperatorId],'.jpg') END as OperatorImageURL,
	   [FirstLoginDateTime],
	   ShiftStartDateTime,
	   FirstLoginTime,
	   [FirstLoad]
FROM [bag].[CONOPS_BAG_OPERATOR_HAS_LATE_START_V] WITH (NOLOCK)
WHERE siteflag = 'BAG'


