CREATE VIEW [dbo].[CONOPS_SHOVEL_INFO_V] AS


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



