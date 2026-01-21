CREATE VIEW [MOR].[CONOPS_MOR_OPERATOR_TRUCK_LOGIN_V] AS






-- SELECT * FROM [mor].[CONOPS_MOR_OPERATOR_TRUCK_LOGIN_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [mor].[CONOPS_MOR_OPERATOR_TRUCK_LOGIN_V] 
AS


WITH OperatorDetail AS (
    SELECT [ShiftFlag]
        ,[SiteFlag]
        ,[ShiftId]
        ,[ShiftIndex]
        ,[TruckID]
        ,[OperatorId] AS [OperatorId]
    FROM [mor].[CONOPS_MOR_TRUCK_DETAIL_V] WITH (NOLOCK)
    WHERE [Operator] != 'NONE'
),

OperatorLogin AS (
   	SELECT DISTINCT [op].ShiftIndex
 			,[sd].Site_Code
			,[op].OperId AS OperatorId
			,[op].EqmtId
			,[op].Unit_Code
			,MIN( dateadd(second, [sd].Starts + [op].Logintime, CAST([sd].shiftdate AS DATETIME))
				) OVER (PARTITION BY [op].OperId, [sd].ShiftIndex) AS FirstLoginTime
			,ROW_NUMBER() OVER (PARTITION BY [op].operid, [sd].shiftindex, [sd].site_code ORDER BY [op].LoginTime) AS rn
	FROM dbo.Shift_Date [sd] WITH(NOLOCK)
	INNER JOIN [dbo].lh_oper_total_sum [op] WITH (NOLOCK)
		ON [sd].ShiftIndex = [op].ShiftIndex
		AND [sd].Site_Code = [op].Site_Code
	WHERE trim([op].OperId) not in ('mmsunk', '')
	AND [op].Unit_Code = 1
	AND trim([sd].Site_Code) = 'MOR'
	AND [op].LoginTime <> 0
),

OperatorLogout AS (
   	SELECT SHiftIndex
    	,Site_Code
        ,Eqmt
		,RIGHT('0000000000' + OperId, 10) AS OperatorId
        ,FieldLogin_Ts AS EndDateTime
		,ROW_NUMBER() OVER (PARTITION BY SHiftIndex
									,Site_Code
									,EQMT
									,OperId
							ORDER BY FieldLogin_Ts DESC) nm
   	FROM dbo.Operator_logout WITH (NOLOCK)
	WHERE Site_Code = 'MOR'
),

OperatorTime AS (
	SELECT [ol].ShiftIndex
		,[ol].Site_Code
		,[ol].OperatorId
		,[ol].EqmtID
		,[ol].FirstLoginTime
		,[oo].EndDateTime
	FROM OperatorLogin [ol]
	LEFT JOIN OperatorLogout [oo]
	ON [ol].ShiftIndex = [oo].ShiftIndex 
		AND [ol].Site_Code = [oo].Site_Code
		AND [ol].OperatorId = [oo].OperatorId 
		AND [ol].EqmtID = [oo].Eqmt
		AND [oo].nm = 1
	WHERE [ol].rn = 1
)

SELECT [od].SHIFTINDEX
     	,a.SHIFTFLAG
     	,a.SITEFLAG
     	,[od].TruckID
     	,RIGHT('0000000000' + [od].OPERATORID, 10) AS OperatorId
     	,[ot].FirstLoginTime AS STARTDATETIME
     	,[ot].ENDDATETIME AS ENDDATETIME
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] a (NOLOCK)
LEFT JOIN OperatorDetail [od]
ON a.SHIFTINDEX = [od].SHIFTINDEX AND a.SITEFLAG = [od].[siteflag]
LEFT JOIN OperatorTime [ot]
ON [ot].SHIFTINDEX = [od].SHIFTINDEX
	AND [ot].SITE_CODE = [od].[siteflag]
  	AND [ot].eqmtid = [od].TruckID
	AND [ot].OperatorId = [od].OPERATORID
WHERE [od].OPERATORID IS NOT NULL



