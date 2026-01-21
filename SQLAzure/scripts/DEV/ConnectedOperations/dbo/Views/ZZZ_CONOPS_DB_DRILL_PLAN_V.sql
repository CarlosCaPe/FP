CREATE VIEW [dbo].[ZZZ_CONOPS_DB_DRILL_PLAN_V] AS


--select * from [dbo].[CONOPS_DB_DRILL_PLAN_V] where shiftflag = 'prev'
CREATE VIEW [dbo].[CONOPS_DB_DRILL_PLAN_V]
AS

SELECT
siteflag,
shiftflag,
eqmt AS Equipment,
HolesDrilled,
FeetDrilled,
HoleShiftTarget,
HoleTarget,
FeetShiftTarget,
FeetTarget,
eqmtcurrstatus
FROM [bag].[CONOPS_BAG_DB_DRILL_PLAN_V]
WHERE siteflag = 'BAG'

UNION ALL


SELECT
siteflag,
shiftflag,
eqmt AS Equipment,
HolesDrilled,
FeetDrilled,
HoleShiftTarget,
HoleTarget,
FeetShiftTarget,
FeetTarget,
eqmtcurrstatus
FROM [mor].[CONOPS_MOR_DB_DRILL_PLAN_V]
WHERE siteflag = 'MOR'


UNION ALL


SELECT
siteflag,
shiftflag,
eqmt AS Equipment,
HolesDrilled,
FeetDrilled,
HoleShiftTarget,
HoleTarget,
FeetShiftTarget,
FeetTarget,
eqmtcurrstatus
FROM [chi].[CONOPS_CHI_DB_DRILL_PLAN_V]
WHERE siteflag = 'CHI'


UNION ALL


SELECT
siteflag,
shiftflag,
eqmt AS Equipment,
HolesDrilled,
FeetDrilled,
HoleShiftTarget,
HoleTarget,
FeetShiftTarget,
FeetTarget,
eqmtcurrstatus
FROM [cli].[CONOPS_CLI_DB_DRILL_PLAN_V]
WHERE siteflag = 'CMX'


UNION ALL


SELECT
siteflag,
shiftflag,
eqmt AS Equipment,
HolesDrilled,
FeetDrilled,
HoleShiftTarget,
HoleTarget,
FeetShiftTarget,
FeetTarget,
eqmtcurrstatus
FROM [sie].[CONOPS_SIE_DB_DRILL_PLAN_V]
WHERE siteflag = 'SIE'


UNION ALL


SELECT
siteflag,
shiftflag,
eqmt AS Equipment,
HolesDrilled,
FeetDrilled,
HoleShiftTarget,
HoleTarget,
FeetShiftTarget,
FeetTarget,
eqmtcurrstatus
FROM [saf].[CONOPS_SAF_DB_DRILL_PLAN_V]
WHERE siteflag = 'SAF'

UNION ALL


SELECT
siteflag,
shiftflag,
eqmt AS Equipment,
HolesDrilled,
FeetDrilled,
HoleShiftTarget,
HoleTarget,
FeetShiftTarget,
FeetTarget,
eqmtcurrstatus
FROM [cer].[CONOPS_CER_DB_DRILL_PLAN_V]
WHERE siteflag = 'CER'


