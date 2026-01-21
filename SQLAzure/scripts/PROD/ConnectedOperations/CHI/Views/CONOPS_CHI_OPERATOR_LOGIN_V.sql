CREATE VIEW [CHI].[CONOPS_CHI_OPERATOR_LOGIN_V] AS

--SELECT * FROM CHI.CONOPS_CHI_OPERATOR_LOGIN_V
CREATE VIEW CHI.CONOPS_CHI_OPERATOR_LOGIN_V
AS

SELECT 
	so.ShiftId,
	so.FieldId AS OperatorId,
	so.FieldName AS OperatorName,
	COALESCE(se.FieldId, sa.FieldId) AS Eqmt,
	COALESCE(fue.Idx, fua.idx) AS UnitCode,
	so.FieldLogin,
	DATEADD(SECOND, so.FieldLogin, si.ShiftStartDateTime) AS FieldLogin_TS,
	so.FieldStatus,
	CASE WHEN so.FieldStatus <> -1 THEN 'Login'
		ELSE 'Logout' END AS StatusType
FROM CHI.Shift_Oper so WITH(NOLOCK)
LEFT JOIN CHI.Shift_Eqmt se WITH(NOLOCK)
	ON so.FieldEqmt = se.Id
LEFT JOIN CHI.Shift_Info si WITH(NOLOCK)
	ON so.ShiftId = si.ShiftId
LEFT JOIN CHI.Enum fue WITH(NOLOCK)
	ON se.FieldUnit = fue.Id
LEFT JOIN CHNOperational.dbo.SHIFTShiftaux sa WITH(NOLOCK)
	ON so.FieldAuxeqmt = sa.Id
LEFT JOIN CHI.Enum fua WITH(NOLOCK)
	ON sa.FieldUnit = fua.Id

