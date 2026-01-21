CREATE VIEW [dbo].[ZZZ_CONOPS_DB_HOLEDRILLED_LINEGRAPH_V] AS


--select * from [dbo].[CONOPS_DB_HOLEDRILLED_LINEGRAPH_V] where shiftflag = 'prev'
CREATE VIEW [dbo].[CONOPS_DB_HOLEDRILLED_LINEGRAPH_V]
AS

SELECT 
siteflag,
shiftflag,
timeseq,
HoleDrilled
FROM [bag].[CONOPS_BAG_DB_HOLEDRILL_SNAPSHOT_V]
WHERE siteflag = 'BAG'


UNION ALL


SELECT 
siteflag,
shiftflag,
timeseq,
HoleDrilled
FROM [cer].[CONOPS_CER_DB_HOLEDRILL_SNAPSHOT_V]
WHERE siteflag = 'CER'


UNION ALL


SELECT 
siteflag,
shiftflag,
timeseq,
HoleDrilled
FROM [chi].[CONOPS_CHI_DB_HOLEDRILL_SNAPSHOT_V]
WHERE siteflag = 'CHI'


UNION ALL


SELECT 
siteflag,
shiftflag,
timeseq,
HoleDrilled
FROM [cli].[CONOPS_CLI_DB_HOLEDRILL_SNAPSHOT_V]
WHERE siteflag = 'CMX'


UNION ALL


SELECT 
siteflag,
shiftflag,
timeseq,
HoleDrilled
FROM [mor].[CONOPS_MOR_DB_HOLEDRILL_SNAPSHOT_V]
WHERE siteflag = 'MOR'


UNION ALL


SELECT 
siteflag,
shiftflag,
timeseq,
HoleDrilled
FROM [saf].[CONOPS_SAF_DB_HOLEDRILL_SNAPSHOT_V]
WHERE siteflag = 'SAF'


UNION ALL


SELECT 
siteflag,
shiftflag,
timeseq,
HoleDrilled
FROM [sie].[CONOPS_SIE_DB_HOLEDRILL_SNAPSHOT_V]
WHERE siteflag = 'SIE'


