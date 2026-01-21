CREATE VIEW [dbo].[ZZZ_CONOPS_DB_FEETDRILLED_LINEGRAPH_V] AS


--select * from [dbo].[CONOPS_DB_FEETDRILLED_LINEGRAPH_V] where siteflag = 'bag' and shiftflag = 'prev'
CREATE VIEW [dbo].[CONOPS_DB_FEETDRILLED_LINEGRAPH_V]
AS

SELECT 
siteflag,
shiftflag,
timeseq,
FeetDrilled
FROM [bag].[CONOPS_BAG_DB_FEETDRILL_SNAPSHOT_V]
WHERE siteflag = 'BAG'
AND timeseq <> '999999'


UNION ALL


SELECT 
siteflag,
shiftflag,
timeseq,
FeetDrilled
FROM [cer].[CONOPS_CER_DB_FEETDRILL_SNAPSHOT_V]
WHERE siteflag = 'CER'
AND timeseq <> '999999'


UNION ALL


SELECT 
siteflag,
shiftflag,
timeseq,
FeetDrilled
FROM [chi].[CONOPS_CHI_DB_FEETDRILL_SNAPSHOT_V]
WHERE siteflag = 'CHI'
AND timeseq <> '999999'


UNION ALL


SELECT 
siteflag,
shiftflag,
timeseq,
FeetDrilled
FROM [cli].[CONOPS_CLI_DB_FEETDRILL_SNAPSHOT_V]
WHERE siteflag = 'CMX'
AND timeseq <> '999999'


UNION ALL


SELECT 
siteflag,
shiftflag,
timeseq,
FeetDrilled
FROM [mor].[CONOPS_MOR_DB_FEETDRILL_SNAPSHOT_V]
WHERE siteflag = 'MOR'
AND timeseq <> '999999'


UNION ALL


SELECT 
siteflag,
shiftflag,
timeseq,
FeetDrilled
FROM [saf].[CONOPS_SAF_DB_FEETDRILL_SNAPSHOT_V]
WHERE siteflag = 'SAF'
AND timeseq <> '999999'


UNION ALL


SELECT 
siteflag,
shiftflag,
timeseq,
FeetDrilled
FROM [sie].[CONOPS_SIE_DB_FEETDRILL_SNAPSHOT_V]
WHERE siteflag = 'SIE'
AND timeseq <> '999999'


