CREATE VIEW [SAF].[CONOPS_SAF_OPERATOR_SHOVEL_LOGIN_V] AS



-- SELECT * FROM [saf].[CONOPS_SAF_OPERATOR_SHOVEL_LOGIN_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'
CREATE VIEW [saf].[CONOPS_SAF_OPERATOR_SHOVEL_LOGIN_V] 
AS

WITH OperatorDetail AS (
    SELECT [shiftflag]
        ,[siteflag]
        ,[shiftid]
        ,[SHIFTINDEX]
        ,[ShovelID]
        ,[StatusName]
        ,[CrewName]
        ,[Location]
		,[Region]
        ,UPPER([Operator]) [Operator]
        ,RIGHT('0000000000' + [OperatorId], 10) [OperatorId]
        ,[OperatorImageURL]
    FROM [saf].[CONOPS_SAF_SHOVEL_INFO_V] WITH (NOLOCK)
    WHERE [Operator] != 'NONE'
),

OperatorLogin AS (
   		SELECT DISTINCT oper.shiftindex
 			  ,eroot.site_code
			  ,RIGHT('0000000000' + oper.operid, 10) operid
			  ,oper.eqmtid
			  ,oper.unit_code
			  ,MIN( dateadd(second, eroot.starts + oper.logintime, CAST(eroot.shiftdate AS DATETIME))
					) OVER (PARTITION BY oper.operid, eroot.shiftindex) AS FirstLoginTime
			  ,ROW_NUMBER() OVER (PARTITION BY oper.operid, eroot.shiftindex, eroot.site_code ORDER BY oper.logintime) AS rn
		FROM dbo.shift_date (nolock) AS eroot
		INNER JOIN dbo.lh_oper_total_sum (nolock) AS oper
		ON eroot.shiftindex = oper.shiftindex
			AND eroot.site_code = oper.site_code
		WHERE trim(oper.operid) not in ('mmsunk', '')
			AND oper.unit_code IN (2)
			AND trim(eroot.site_code) = 'SAF'
			AND oper.logintime <> 0
	),

	OperatorLogout AS (
   		SELECT SHIFTINDEX
         	  ,SITE_CODE
         	  ,[ol].EQMT AS ShovelID
			  ,RIGHT('0000000000' + [ol].OPERID, 10) AS OPERATORID
         	  ,[ol].FIELDLOGIN_TS AS ENDDATETIME
			  ,ROW_NUMBER() OVER (PARTITION BY [ol].SHIFTINDEX, [ol].SITE_CODE, [ol].EQMT, [ol].OPERID
							      ORDER BY [ol].FIELDLOGIN_TS DESC) nm
   		FROM dbo.OPERATOR_LOGOUT [ol] WITH (NOLOCK)
		WHERE [ol].SITE_CODE = 'SAF'
	),

	OperatorTime AS (
		SELECT [ol].SHIFTINDEX
			  ,[ol].site_code
			  ,[ol].operid
			  ,[ol].EQMTID
			  ,[ol].FirstLoginTime
			  ,[oo].ENDDATETIME
		FROM OperatorLogin [ol]
		LEFT JOIN OperatorLogout [oo]
		ON [ol].SHIFTINDEX = [oo].SHIFTINDEX AND [ol].site_code = [oo].SITE_CODE
		   AND [ol].operid = [oo].OPERATORID AND [ol].EQMTID = [oo].ShovelID
		   AND [oo].nm = 1
		WHERE [ol].rn = 1
	)

SELECT [od].SHIFTINDEX
     	  ,a.SHIFTFLAG
     	  ,a.SITEFLAG
     	  ,[od].[ShovelID]
     	  ,[od].OPERATORID
     	  ,[ot].FirstLoginTime AS STARTDATETIME
     	  ,[ot].ENDDATETIME AS ENDDATETIME
	FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] a (NOLOCK)
	LEFT JOIN OperatorDetail [od]
	ON a.SHIFTINDEX = [od].SHIFTINDEX AND a.SITEFLAG = [od].[siteflag]
	LEFT JOIN OperatorTime [ot]
	ON [ot].SHIFTINDEX = [od].SHIFTINDEX AND [ot].SITE_CODE = [od].[siteflag]
  	   AND [ot].eqmtid = [od].[ShovelID] AND [ot].operid = [od].OPERATORID
	WHERE [od].OPERATORID IS NOT NULL


