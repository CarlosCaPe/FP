CREATE VIEW [BAG].[CONOPS_BAG_OPERATOR_DRILL_LOGIN_V] AS

-- SELECT * FROM [BAG].[CONOPS_BAG_OPERATOR_DRILL_LOGIN_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'
CREATE VIEW [bag].[CONOPS_BAG_OPERATOR_DRILL_LOGIN_V] 
AS

WITH OperatorDetail AS (
SELECT [ShiftFlag]
	,[SiteFlag]
	,[ShiftId]
	,[ShiftIndex]
	,[DRILL_ID]
	,[OperatorId] AS [OperatorId]
FROM [bag].[CONOPS_BAG_DRILL_DETAIL_V] WITH (NOLOCK)
WHERE OperatorID IS NOT NULL
),

OperatorTime AS (
SELECT DISTINCT
	SHIFTID,
	MACHINE_NAME AS EqmtID,
	OPERATOR_ID AS OperatorId,
	MIN(LOGIN_LOCAL_TIME) OVER (PARTITION BY shiftid, MACHINE_NAME, OPERATOR_ID) AS FirstLoginTime,
	MIN(LOGOUT_LOCAL_TIME) OVER (PARTITION BY shiftid, MACHINE_NAME, OPERATOR_ID) AS LastLogoutTime
FROM BAG.FLEET_OPERATOR_SHIFT_V
)

SELECT
	[od].SHIFTINDEX
	,a.SHIFTFLAG
	,a.SITEFLAG
	,[od].DRILL_ID
	,RIGHT('0000000000' + [od].OPERATORID, 10) AS OperatorId
	,[ot].FirstLoginTime AS STARTDATETIME
	,[ot].LastLogoutTime AS ENDDATETIME
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a (NOLOCK)
LEFT JOIN OperatorDetail [od]
	ON a.shiftid = [od].shiftid
LEFT JOIN OperatorTime [ot]
	ON [ot].shiftid = [od].shiftid
  	AND [ot].eqmtid = [od].DRILL_ID
	AND [ot].OperatorId = [od].OPERATORID
WHERE [od].OPERATORID IS NOT NULL

