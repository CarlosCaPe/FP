CREATE VIEW [dbo].[ZZZ_CONOPS_DB_FEETDRILL_SNAP_V] AS


--select * from [dbo].[CONOPS_DB_FEETDRILL_SNAP_V] where shiftflag = 'prev'
CREATE VIEW [dbo].[CONOPS_DB_FEETDRILL_SNAP_V]
AS

SELECT 
siteflag,
shiftflag,
DrillTime,
FeetDrilled,
FeetShiftTarget,
FeetTarget
FROM [bag].[CONOPS_BAG_DB_FEETDRILL_SNAPSHOT_V]
WHERE siteflag = 'BAG'


UNION ALL


SELECT 
siteflag,
shiftflag,
DrillTime,
FeetDrilled,
FeetShiftTarget,
FeetTarget
FROM [cer].[CONOPS_CER_DB_FEETDRILL_SNAPSHOT_V]
WHERE siteflag = 'CER'


UNION ALL


SELECT 
siteflag,
shiftflag,
DrillTime,
FeetDrilled,
FeetShiftTarget,
FeetTarget
FROM [chi].[CONOPS_CHI_DB_FEETDRILL_SNAPSHOT_V]
WHERE siteflag = 'CHI'


UNION ALL


SELECT 
siteflag,
shiftflag,
DrillTime,
FeetDrilled,
FeetShiftTarget,
FeetTarget
FROM [cli].[CONOPS_CLI_DB_FEETDRILL_SNAPSHOT_V]
WHERE siteflag = 'CMX'



UNION ALL


SELECT 
siteflag,
shiftflag,
DrillTime,
FeetDrilled,
FeetShiftTarget,
FeetTarget
FROM [mor].[CONOPS_MOR_DB_FEETDRILL_SNAPSHOT_V]
WHERE siteflag = 'MOR'


UNION ALL


SELECT 
siteflag,
shiftflag,
DrillTime,
FeetDrilled,
FeetShiftTarget,
FeetTarget
FROM [saf].[CONOPS_SAF_DB_FEETDRILL_SNAPSHOT_V]
WHERE siteflag = 'SAF'



UNION ALL


SELECT 
siteflag,
shiftflag,
DrillTime,
FeetDrilled,
FeetShiftTarget,
FeetTarget
FROM [sie].[CONOPS_SIE_DB_FEETDRILL_SNAPSHOT_V]
WHERE siteflag = 'SIE'



