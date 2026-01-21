CREATE VIEW [CHI].[SHIFT_DUMP_V] AS

CREATE VIEW [CHI].[SHIFT_DUMP_V] 
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
        FieldTimedump,
        FieldTimeempty,
        FieldTimedigest,
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
        FieldTimeemptymobile,
        FieldMeasuretime,
        FieldWeightst
    FROM CHI.SHIFT_DUMP WITH (NOLOCK)
)
SELECT 
    a.siteflag,
    a.shiftid,
    a.OrigShiftid,
    a.Id,
    a.FieldLoc,
    a.FieldExcav,
    a.FieldLsizetons,
    a.FieldLoad,
    a.FieldTimedump,
    a.FieldLoadrec,
    a.FieldTimeempty,
    a.FieldTimearrive,
    a.FieldTruck,
    a.FieldLsizedb,
    a.FieldBlast,
	DATEADD(SECOND, FieldTimedump, orisi.ShiftStartDateTime) AS DUMPTIME_TS,
	DATEDIFF(SECOND, si.ShiftStartDateTime, DATEADD(SECOND, FieldTimedump, orisi.ShiftStartDateTime)) / 3600 AS DUMPTIME_HOS
FROM CTE a
LEFT JOIN CHI.shift_info orisi
	ON a.OrigShiftid = orisi.shiftid
LEFT JOIN CHI.shift_info si
	ON a.Shiftid = si.shiftid




