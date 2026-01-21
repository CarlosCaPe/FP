CREATE VIEW [SIE].[CONOPS_SIE_OPERATOR_LOGIN_V] AS

--SELECT * FROM SIE.CONOPS_SIE_OPERATOR_LOGIN_V
CREATE VIEW SIE.CONOPS_SIE_OPERATOR_LOGIN_V
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
FROM SIE.Shift_Oper so WITH(NOLOCK)
LEFT JOIN SIE.Shift_Eqmt se WITH(NOLOCK)
	ON so.FieldEqmt = se.Id
LEFT JOIN SIE.Shift_Info si WITH(NOLOCK)
	ON so.ShiftId = si.ShiftId
LEFT JOIN SIE.Enum fue WITH(NOLOCK)
	ON se.FieldUnit = fue.Id
LEFT JOIN SIEOperational.dbo.SHIFTShiftaux sa WITH(NOLOCK)
	ON so.FieldAuxeqmt = sa.Id
LEFT JOIN SIE.Enum fua WITH(NOLOCK)
	ON sa.FieldUnit = fua.Id

