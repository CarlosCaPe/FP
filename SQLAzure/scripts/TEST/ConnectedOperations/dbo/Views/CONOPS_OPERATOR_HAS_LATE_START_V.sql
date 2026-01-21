CREATE VIEW [dbo].[CONOPS_OPERATOR_HAS_LATE_START_V] AS






-- SELECT * FROM [dbo].[CONOPS_OPERATOR_HAS_LATE_START_V] WITH (NOLOCK) WHERE siteflag = 'CHI'
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
FROM [saf].[CONOPS_SAF_OPERATOR_HAS_LATE_START_V] WITH (NOLOCK)
WHERE siteflag = 'SAF'



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
FROM [sie].[CONOPS_SIE_OPERATOR_HAS_LATE_START_V] WITH (NOLOCK)
WHERE siteflag = 'SIE'

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
FROM [chi].[CONOPS_CHI_OPERATOR_HAS_LATE_START_V] WITH (NOLOCK)
WHERE siteflag = 'CHI'


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
FROM [cli].[CONOPS_CLI_OPERATOR_HAS_LATE_START_V] WITH (NOLOCK)
WHERE siteflag = 'CMX'



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
FROM [cer].[CONOPS_CER_OPERATOR_HAS_LATE_START_V] WITH (NOLOCK)
WHERE siteflag = 'CER'


