CREATE VIEW [BAG].[FLEET_PIT_MACHINE_V] AS

--SELECT * FROM [BAG].[FLEET_PIT_MACHINE_V] 
CREATE VIEW [BAG].[FLEET_PIT_MACHINE_V]     
AS  

WITH CTE AS(
SELECT
	sh.siteflag COLLATE SQL_Latin1_General_CP1_CI_AS AS siteflag,
	sh.shiftid,
	sh.shiftindex,
	m.NAME COLLATE SQL_Latin1_General_CP1_CI_AS AS EquipmentID,
	MCA.NAME COLLATE SQL_Latin1_General_CP1_CI_AS AS EquipmentCategory,
	mc.NAME COLLATE SQL_Latin1_General_CP1_CI_AS AS EQMTTYPE,
	p.STATUS AS StatusCode,
	DATEADD(HH, sh.current_utc_offset, p.STATUS_LAST_UPDATED_UTC) AS StatusStart,
	DATEDIFF(MINUTE, p.STATUS_LAST_UPDATED_UTC, GETUTCDATE()) AS TimeInState,
	CONCAT('Crew', sh.crewid) COLLATE SQL_Latin1_General_CP1_CI_AS AS CrewName,
	l.NAME COLLATE SQL_Latin1_General_CP1_CI_AS AS Location,
	NULL AS Region,
	op.NAME COLLATE SQL_Latin1_General_CP1_CI_AS AS Operator,
	op.PersonnelID AS OperatorId,
	s.NAME COLLATE SQL_Latin1_General_CP1_CI_AS AS AssignedShovel,
	p.X AS FieldX,
	p.Y AS FieldY,
	p.Z AS FieldZ,
	p.SPEED AS FieldVelocity
FROM BAG_MSPITMODEL.dbo.MACHINE_IN_PIT p
LEFT JOIN BAG_MSMODEL.dbo.MACHINE m
	ON p.MACHINE_OID = m.MACHINE_OID
LEFT JOIN BAG_MSMODEL.dbo.MACHINECLASS mc
	ON m.CLASS = mc.MACHINECLASS_OID
LEFT JOIN BAG_MSMODEL.dbo.MACHINECATEGORY mca
	ON mc.CATEGORY = mca.MACHINECATEGORY_OID
LEFT JOIN BAG_MSMODEL.dbo.LOCATION l
	ON l.LOCATION_OID = p.LOCATION_OID
LEFT JOIN BAG_MSMODEL.dbo.PERSON op
	ON op.PERSON_OID = p.CURRENT_OPERATOR_OID
LEFT JOIN BAG_MSMODEL.dbo.MACHINE s
	ON p.LAST_LOADER_OID = s.MACHINE_OID
LEFT JOIN ConnectedOperations.BAG.CONOPS_BAG_SHIFT_INFO_V sh
	ON sh.shiftflag = 'CURR'
WHERE m.IS_ACTIVE = 1 --exclude inactive equipment
),

AddSeq AS(
SELECT	
	siteflag,
	shiftid,
	shiftindex,
	EquipmentID,
	EquipmentCategory,
	EQMTTYPE,
	StatusCode,
	StatusStart,
	TimeInState,
	CrewName,
	Location,
	Region,
	Operator,
	OperatorId,
	AssignedShovel,
	FieldX,
	FieldY,
	FieldZ,
	FieldVelocity,
	ROW_NUMBER() OVER (PARTITION BY OperatorId ORDER BY EquipmentId ASC) as seqnum
FROM CTE
)

SELECT
	siteflag,
	shiftid,
	shiftindex,
	EquipmentID,
	EquipmentCategory,
	EQMTTYPE,
	StatusCode,
	StatusStart,
	TimeInState,
	CrewName,
	Location,
	Region,
	Operator,
	OperatorId,
	AssignedShovel,
	FieldX,
	FieldY,
	FieldZ,
	FieldVelocity
FROM AddSeq
WHERE seqnum = 1 OR OperatorId IS NULL

