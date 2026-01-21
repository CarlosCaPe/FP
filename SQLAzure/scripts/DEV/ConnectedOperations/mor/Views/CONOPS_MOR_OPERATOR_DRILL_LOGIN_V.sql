CREATE VIEW [mor].[CONOPS_MOR_OPERATOR_DRILL_LOGIN_V] AS


-- SELECT * FROM [mor].[CONOPS_MOR_OPERATOR_DRILL_LOGIN_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'
CREATE VIEW [mor].[CONOPS_MOR_OPERATOR_DRILL_LOGIN_V] 
AS

	WITH OperatorDetail AS (
   		SELECT [ds].SHIFTINDEX,
          	   [ds].[SITE_CODE],
          	   REPLACE(DRILL_ID, ' ','') AS DRILL_ID,
          	   OPERATORID,
          	   ROW_NUMBER() OVER (PARTITION BY [ds].SHIFTINDEX, [ds].SITE_CODE, Drill_ID
                             	  ORDER BY END_HOLE_TS DESC) num
   		FROM [dbo].[FR_DRILLING_SCORES] [ds] WITH (NOLOCK)
   		WHERE DRILL_ID IS NOT NULL AND [ds].[SITE_CODE] = 'MOR'
	),

	OperatorLogin AS (
   		SELECT SHIFTINDEX
         	  ,SITE_CODE
         	  ,DRILL_ID
         	  ,StartDateTime
         	  ,ROW_NUMBER() OVER (PARTITION BY SHIFTINDEX, SITE_CODE, Drill_ID
                             	  ORDER BY StartDateTime ASC) num
   		FROM [mor].[drill_asset_efficiency_v] WITH (NOLOCK)
   		WHERE StatusIdx = 2
	),

	OperatorLogout AS (
   		SELECT SHIFTINDEX
         	  ,SITE_CODE
         	  ,DRILL_ID
         	  ,ENDDATETIME
         	  ,ROW_NUMBER() OVER (PARTITION BY SHIFTINDEX, SITE_CODE, Drill_ID
                             	  ORDER BY ENDDATETIME DESC) num
   		FROM [mor].[drill_asset_efficiency_v] WITH (NOLOCK)
   		WHERE StatusIdx = 2
	)

	SELECT [od].SHIFTINDEX
     	  ,a.SHIFTFLAG
     	  ,a.SITEFLAG
     	  ,[od].DRILL_ID
     	  ,[od].OPERATORID
     	  ,[ol].STARTDATETIME
     	  ,[olo].ENDDATETIME
	FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] a (NOLOCK)
	LEFT JOIN OperatorDetail [od]
	ON a.SHIFTINDEX = [od].SHIFTINDEX AND a.SITEFLAG = [od].SITE_CODE
	LEFT JOIN OperatorLogin [ol]
	ON [ol].SHIFTINDEX = [od].SHIFTINDEX AND [ol].SITE_CODE = [od].SITE_CODE
  	   AND [ol].DRILL_ID = [od].DRILL_ID
  	   AND [ol].num = 1
	LEFT JOIN OperatorLogout [olo]
	ON [olo].SHIFTINDEX = [od].SHIFTINDEX AND [olo].SITE_CODE = [od].SITE_CODE
  	   AND [olo].DRILL_ID = [od].DRILL_ID
  	   AND [olo].num = 1
	WHERE [od].num = 1
     	  AND [od].OPERATORID IS NOT NULL

