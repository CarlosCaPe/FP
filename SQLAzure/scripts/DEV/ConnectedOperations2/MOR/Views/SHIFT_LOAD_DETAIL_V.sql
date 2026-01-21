CREATE VIEW [MOR].[SHIFT_LOAD_DETAIL_V] AS

CREATE VIEW MOR.SHIFT_LOAD_DETAIL_V
AS

SELECT
	sl.SiteFlag,
	sl.ShiftId,
	si.SHIFTINDEX,
	eqe.FieldId AS Excav,
	oe.FieldId AS Excav_OperatorId,
	oe.FieldName AS Excav_OperatorName,
	eqt.FieldId AS Truck,
	te.FieldId AS Truck_OperatorId,
	te.FieldName AS Truck_OperatorName,
	sl.FieldTons,
	sl.FieldLsizetons,
	sg.FieldId AS Grade,
	slo.FieldId AS Loc,
	sl.FieldTimearrive,
	DATEADD(SECOND, sl.FieldTimeload, si.ShiftStartDateTime) AS TimeArrive_TS,
	sl.FieldTimefull,
	DATEADD(SECOND, sl.FieldTimeload, si.ShiftStartDateTime) AS TimeFull_TS,
	DATEDIFF(HOUR, si.ShiftStartDateTime, DATEADD(SECOND, sl.FieldTimeload, si.ShiftStartDateTime)) AS TimeFull_HOS,
	sl.FieldTimeload,
	DATEADD(SECOND, sl.FieldTimeload, si.ShiftStartDateTime) AS TimeLoad_TS
FROM mor.shift_load sl WITH(NOLOCK)
LEFT JOIN mor.SHIFT_INFO si WITH(NOLOCK)
	ON sl.ShiftId = si.ShiftId
LEFT JOIN mor.shift_eqmt eqe WITH(NOLOCK)
	ON sl.FieldExcav = eqe.Id
LEFT JOIN mor.shift_eqmt eqt WITH(NOLOCK)
	ON sl.FieldTruck = eqt.Id
LEFT JOIN mor.SHIFT_OPER oe WITH(NOLOCK)
	ON sl.FieldEoper = oe.Id
LEFT JOIN mor.SHIFT_OPER te WITH(NOLOCK)
	ON sl.FieldToper = te.Id
LEFT JOIN mor.shift_grade sg WITH(NOLOCK)
	ON sl.FieldGrade = sg.Id
LEFT JOIN mor.SHIFT_LOC slo WITH(NOLOCK)
	ON sl.FieldLoc = slo.Id
INNER JOIN dbo.PAYLOAD_FILTER AS pf WITH (NOLOCK)
	ON pf.SITEFLAG = sl.SiteFlag
WHERE (pf.PayloadFilterLower IS NULL OR FieldTons >= pf.PayloadFilterLower)
	AND (pf.PayloadFilterUpper IS NULL OR FieldTons <= pf.PayloadFilterUpper)


