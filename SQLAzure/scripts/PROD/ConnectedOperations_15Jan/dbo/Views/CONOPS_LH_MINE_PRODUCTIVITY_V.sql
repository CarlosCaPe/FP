CREATE VIEW [dbo].[CONOPS_LH_MINE_PRODUCTIVITY_V] AS


CREATE VIEW [dbo].[CONOPS_LH_MINE_PRODUCTIVITY_V]
AS

SELECT 
siteflag,
shiftflag,
shiftid,
mineproductivity,
mineproductivitytarget as [target]
FROM [mor].[CONOPS_MOR_MINE_PRODUCTIVITY_V]
WHERE siteflag = 'MOR'

UNION ALL

SELECT 
siteflag,
shiftflag,
shiftid,
mineproductivity,
mineproductivitytarget as [target]
FROM [bag].[CONOPS_BAG_MINE_PRODUCTIVITY_V]
WHERE siteflag = 'BAG'


