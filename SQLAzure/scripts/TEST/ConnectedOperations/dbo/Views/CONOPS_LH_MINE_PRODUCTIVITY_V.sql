CREATE VIEW [dbo].[CONOPS_LH_MINE_PRODUCTIVITY_V] AS



--select * from [dbo].[CONOPS_LH_MINE_PRODUCTIVITY_V]
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

UNION ALL

SELECT siteflag,
	   shiftflag,
	   shiftid,
	   mineproductivity,
	   mineproductivitytarget as [target]
FROM [saf].[CONOPS_SAF_MINE_PRODUCTIVITY_V]
WHERE siteflag = 'SAF'


UNION ALL

SELECT siteflag,
	   shiftflag,
	   shiftid,
	   mineproductivity,
	   mineproductivitytarget as [target]
FROM [sie].[CONOPS_SIE_MINE_PRODUCTIVITY_V]
WHERE siteflag = 'SIE'


UNION ALL

SELECT siteflag,
	   shiftflag,
	   shiftid,
	   mineproductivity,
	   mineproductivitytarget as [target]
FROM [cli].[CONOPS_CLI_MINE_PRODUCTIVITY_V]
WHERE siteflag = 'CMX'

UNION ALL

SELECT siteflag,
	   shiftflag,
	   shiftid,
	   mineproductivity,
	   mineproductivitytarget as [target]
FROM [chi].[CONOPS_CHI_MINE_PRODUCTIVITY_V]
WHERE siteflag = 'CHI'


UNION ALL

SELECT siteflag,
	   shiftflag,
	   shiftid,
	   mineproductivity,
	   mineproductivitytarget as [target]
FROM [cer].[CONOPS_CER_MINE_PRODUCTIVITY_V]
WHERE siteflag = 'CER'


