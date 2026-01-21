CREATE VIEW [SAF].[CONOPS_SAF_OPERATOR_LOGIN_V] AS

--SELECT * FROM SAF.CONOPS_SAF_OPERATOR_LOGIN_V
CREATE VIEW SAF.CONOPS_SAF_OPERATOR_LOGIN_V
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
FROM SAF.Shift_Oper so WITH(NOLOCK)
LEFT JOIN SAF.Shift_Eqmt se WITH(NOLOCK)
	ON so.FieldEqmt = se.Id
LEFT JOIN SAF.Shift_Info si WITH(NOLOCK)
	ON so.ShiftId = si.ShiftId
LEFT JOIN SAF.Enum fue WITH(NOLOCK)
	ON se.FieldUnit = fue.Id
LEFT JOIN SAFOperational.dbo.SHIFTShiftaux sa WITH(NOLOCK)
	ON so.FieldAuxeqmt = sa.Id
LEFT JOIN SAF.Enum fua WITH(NOLOCK)
	ON sa.FieldUnit = fua.Id

