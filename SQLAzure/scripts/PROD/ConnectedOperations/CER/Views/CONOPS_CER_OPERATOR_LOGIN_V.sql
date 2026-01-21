CREATE VIEW [CER].[CONOPS_CER_OPERATOR_LOGIN_V] AS

--SELECT * FROM CER.CONOPS_CER_OPERATOR_LOGIN_V
CREATE VIEW CER.CONOPS_CER_OPERATOR_LOGIN_V
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
FROM CER.Shift_Oper so WITH(NOLOCK)
LEFT JOIN CER.Shift_Eqmt se WITH(NOLOCK)
	ON so.FieldEqmt = se.Shift_Eqmt_Id
LEFT JOIN CER.Shift_Info si WITH(NOLOCK)
	ON so.ShiftId = si.ShiftId
LEFT JOIN CER.Enum fue WITH(NOLOCK)
	ON se.FieldUnit = fue.Enum_Id
LEFT JOIN CVEOperational.dbo.SHIFTShiftaux sa WITH(NOLOCK)
	ON so.FieldAuxeqmt = sa.Id
LEFT JOIN CER.Enum fua WITH(NOLOCK)
	ON sa.FieldUnit = fua.Enum_Id

