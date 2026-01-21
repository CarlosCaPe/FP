CREATE VIEW [MOR].[SHIFT_DUMP_DETAIL_V] AS

--SELECT * FROM MOR.SHIFT_DUMP_DETAIL_V
CREATE VIEW [MOR].[SHIFT_DUMP_DETAIL_V]
AS

WITH CTE AS (
SELECT
	DbPrevious,
	DbNext,
	DbVersion,
	CASE 
		WHEN fieldtimedump >= 43200 THEN
			CASE 
				WHEN RIGHT(shiftid, 1) = '1' THEN CONCAT(LEFT(shiftid, 8), '2')
				ELSE CONCAT(RIGHT(CONVERT(VARCHAR(8), DATEADD(DAY, 1, CONVERT(DATETIME, CONCAT('20', LEFT(shiftid, 6)), 112)), 112), 6), '001')
			END
		ELSE shiftid 
	END AS shiftid,
	shiftid AS [OrigShiftid],
	siteflag,
	Id,
	DbName,
	DbKey,
	FieldId,
	FieldTruck,
	FieldLoc,
	FieldGrade,
	FieldLoadrec,
	FieldExcav,
	FieldBlast,
	FieldBay,
	FieldTons,
	FieldTimearrive,
	CASE 
		WHEN fieldtimedump >= 43200 THEN fieldtimedump - 43200
		ELSE fieldtimedump END AS FieldTimedump,
	CASE 
		WHEN FieldTimeempty >= 43200 THEN FieldTimeempty - 43200
		ELSE FieldTimeempty END AS FieldTimeempty,
	CASE 
		WHEN FieldTimedigest >= 43200 THEN FieldTimedigest - 43200
		ELSE FieldTimedigest END AS FieldTimedigest,
	--FieldTimedigest,
	FieldCalctravtime,
	FieldLoad,
	FieldExtraload,
	FieldDist,
	FieldEfh,
	FieldLoadtype,
	FieldToper,
	FieldEoper,
	FieldOrigasn,
	FieldReasnby,
	FieldPathtravtime,
	FieldExptraveltime,
	FieldExptraveldist,
	FieldGpstraveldist,
	FieldLocactlc,
	FieldLocacttp,
	FieldLocactrl,
	FieldAudit,
	FieldGpsxtkd,
	FieldGpsytkd,
	FieldGpsstat,
	FieldGpshead,
	FieldGpsvel,
	FieldLsizetons,
	FieldLsizeid,
	FieldLsizeversion,
	FieldLsizedb,
	FieldFactapply,
	FieldDlock,
	FieldElock,
	FieldEdlock,
	FieldRlock,
	FieldReconstat,
	FieldTimearrivemobile,
	FieldTimedumpmobile,
	FieldTimeemptymobile
FROM MOR.SHIFT_DUMP WITH (NOLOCK)
)

SELECT
	si.SiteFlag,
	sd.ShiftId,
	sd.OrigShiftid,
	NULL AS ShiftIndex,
	eqe.FieldId AS Excav,
	NULL AS Excav_OperatorId,
	NULL AS Excav_OperatorName,
	eqt.FieldId AS Truck,
	NULL AS Truck_OperatorId,
	NULL AS Truck_OperatorName,
	sd.FieldTons,
	sd.FieldLsizetons,
	--sg.FieldId AS Grade,
	sdo.FieldId AS Loc,
	FLOOR(DATEDIFF(SECOND, si.ShiftStartDateTime, DATEADD(SECOND, FieldTimedump, si.ShiftStartDateTime)) / 3600.00) AS DUMPTIME_HOS,
	sd.FieldTimearrive,
	DATEADD(SECOND, sd.FieldTimearrive, si.ShiftStartDateTime ) AS TimeArrive_TS,
	sd.FieldTimedigest,
	DATEADD(SECOND, sd.FieldTimedigest, si.ShiftStartDateTime ) AS TimeDigest_TS,
	sd.fieldtimedump,
	DATEADD(SECOND, sd.fieldtimedump, si.ShiftStartDateTime ) AS TimeDump_TS,
	sd.FieldTimeempty,
	DATEADD(SECOND, sd.FieldTimeempty, si.ShiftStartDateTime ) AS TimeEmpty_TS
FROM CTE sd WITH(NOLOCK)
LEFT JOIN MOR.SHIFT_INFO si WITH(NOLOCK)
	ON sd.ShiftId = si.ShiftId
LEFT JOIN MOR.shift_eqmt eqe WITH(NOLOCK)
	ON sd.FieldExcav = eqe.Id
LEFT JOIN MOR.shift_eqmt eqt WITH(NOLOCK)
	ON sd.FieldTruck = eqt.Id
--LEFT JOIN MOR.SHIFT_OPER oe WITH(NOLOCK)
--	ON sd.FieldEoper = oe.Id
--LEFT JOIN MOR.SHIFT_OPER te WITH(NOLOCK)
--	ON sd.FieldToper = te.Id
--LEFT JOIN MOR.shift_grade sg WITH(NOLOCK)
--	ON sd.FieldGrade = sg.Id
LEFT JOIN MOR.SHIFT_LOC sdo WITH(NOLOCK)
	ON sd.FieldLoc = sdo.Id


