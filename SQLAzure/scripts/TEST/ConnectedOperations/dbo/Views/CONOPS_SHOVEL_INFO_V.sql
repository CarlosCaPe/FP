CREATE VIEW [dbo].[CONOPS_SHOVEL_INFO_V] AS



-- SELECT * FROM [dbo].[CONOPS_SHOVEL_INFO_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [dbo].[CONOPS_SHOVEL_INFO_V]
AS

SELECT [shiftflag],
	   [siteflag],
	   [ShovelID],
	   [Location],
	   [Region],
	   [StatusCode],
	   [StatusName],
	   [StatusStart],
	   [OperatorId],
	   [Operator],
	   [OperatorImageURL]
FROM [mor].[CONOPS_MOR_SHOVEL_INFO_V] WITH (NOLOCK)
WHERE siteflag = 'MOR'

UNION ALL

SELECT [shiftflag],
	   [siteflag],
	   [ShovelID],
	   [Location],
	   [Region],
	   [StatusCode],
	   [StatusName],
	   [StatusStart],
	   [OperatorId],
	   [Operator],
	   [OperatorImageURL]
FROM [bag].[CONOPS_BAG_SHOVEL_INFO_V] WITH (NOLOCK)
WHERE siteflag = 'BAG'

UNION ALL

SELECT [shiftflag],
	   [siteflag],
	   [ShovelID],
	   [Location],
	   [Region],
	   [StatusCode],
	   [StatusName],
	   [StatusStart],
	   [OperatorId],
	   [Operator],
	   [OperatorImageURL]
FROM [saf].[CONOPS_SAF_SHOVEL_INFO_V] WITH (NOLOCK)
WHERE siteflag = 'SAF'



UNION ALL

SELECT [shiftflag],
	   [siteflag],
	   [ShovelID],
	   [Location],
	   [Region],
	   [StatusCode],
	   [StatusName],
	   [StatusStart],
	   [OperatorId],
	   [Operator],
	   [OperatorImageURL]
FROM [sie].[CONOPS_SIE_SHOVEL_INFO_V] WITH (NOLOCK)
WHERE siteflag = 'SIE'


UNION ALL

SELECT [shiftflag],
	   [siteflag],
	   [ShovelID],
	   [Location],
	   [Region],
	   [StatusCode],
	   [StatusName],
	   [StatusStart],
	   [OperatorId],
	   [Operator],
	   [OperatorImageURL]
FROM [cer].[CONOPS_CER_SHOVEL_INFO_V] WITH (NOLOCK)
WHERE siteflag = 'CER'


UNION ALL

SELECT [shiftflag],
	   [siteflag],
	   [ShovelID],
	   [Location],
	   [Region],
	   [StatusCode],
	   [StatusName],
	   [StatusStart],
	   [OperatorId],
	   [Operator],
	   [OperatorImageURL]
FROM [chi].[CONOPS_CHI_SHOVEL_INFO_V] WITH (NOLOCK)
WHERE siteflag = 'CHI'


UNION ALL

SELECT [shiftflag],
	   [siteflag],
	   [ShovelID],
	   [Location],
	   [Region],
	   [StatusCode],
	   [StatusName],
	   [StatusStart],
	   [OperatorId],
	   [Operator],
	   [OperatorImageURL]
FROM [cli].[CONOPS_CLI_SHOVEL_INFO_V] WITH (NOLOCK)
WHERE siteflag = 'CMX'

