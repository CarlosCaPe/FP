





/******************************************************************
* PROCEDURE : DBO.[UPSERT_CONOPS_SHOVEL_POPUP]
* PURPOSE : UPSERT [UPSERT_CONOPS_SHOVEL_POPUP]
* NOTES : 
* CREATED : GGOSAL1
* SAMPLE: EXEC DBO.[UPSERT_CONOPS_SHOVEL_POPUP] 'CER'
* MODIFIED DATE		AUTHOR			DESCRIPTION
*------------------------------------------------------------------
* {15 APR 2024}		{GGOSAL1}		{INITIAL CREATED}
*******************************************************************/
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_SHOVEL_POPUP]    
(      
@G_SITE VARCHAR(5)      
)      
AS      
BEGIN
--DECLARE @G_SITE_ALIAS VARCHAR(5)

--SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' ELSE @G_SITE END

EXEC       
( 

' DELETE FROM ' +@G_SITE+ '.CONOPS_' +@G_SITE+ '_SHOVEL_POPUP_STG ; '

+' INSERT INTO ' +@G_SITE+ '.CONOPS_' +@G_SITE+ '_SHOVEL_POPUP_STG '
+' SELECT * FROM ' +@G_SITE+ '.CONOPS_' +@G_SITE+ '_SHOVEL_POPUP_V; '

+'MERGE ' +@G_SITE+ '.CONOPS_' +@G_SITE+ '_SHOVEL_POPUP AS T '      
+' USING (SELECT '     
+' [shiftflag] '
+' ,[siteflag] '
+' ,[shiftid] '
+' ,[shiftindex] '
+' ,[ShovelID] '
+' ,[eqmttype] '
+' ,[Operator] '
+' ,[OperatorId] '
+' ,[OperatorImageURL] '
+' ,[ReasonId] '
+' ,[ReasonDesc] '
+' ,[TotalMaterialMined] '
+' ,[TotalMaterialMinedTarget] '
+' ,[TotalMaterialMoved] '
+' ,[TotalMaterialMovedTarget] '
+' ,[Payload] '
+' ,[PayloadTarget] '
+' ,[deltac] '
+' ,[DeltaCTarget] '
+' ,[IdleTime] '
+' ,[IdleTimeTarget] '
+' ,[Spotting] '
+' ,[SpottingTarget] '
+' ,[Loading] '
+' ,[LoadingTarget] '
+' ,[Dumping] '
+' ,[DumpingTarget] '
+' ,[HangTime] '
+' ,[HangTimeTarget] '
+' ,[EFH] '
+' ,[EFHTarget] '
+' ,[NumberOfLoads] '
+' ,[NumberOfLoadsTarget] '
+' ,[TonsPerReadyHour] '
+' ,[TonsPerReadyHourTarget] '
+' ,[AssetEfficiency] '
+' ,[AssetEfficiencyTarget] '
+' ,[Availability] '
+' ,[AvailabilityTarget] '
+' FROM ' +@G_SITE+ '.CONOPS_' +@G_SITE+ '_SHOVEL_POPUP_STG) AS S '      
+' ON (T.SITEFLAG = S.SITEFLAG AND T.SHIFTID = S.SHIFTID AND T.ShovelID = S.ShovelID) '       
+' WHEN MATCHED '       
+' THEN UPDATE SET '       
+' T.shiftflag = S.shiftflag, '
+' T.shiftindex = S.shiftindex, '
+' T.eqmttype = S.eqmttype, '
+' T.Operator = S.Operator, '
+' T.OperatorId = S.OperatorId, '
+' T.OperatorImageURL = S.OperatorImageURL, '
+' T.ReasonId = S.ReasonId, '
+' T.ReasonDesc = S.ReasonDesc, '
+' T.TotalMaterialMined = S.TotalMaterialMined, '
+' T.TotalMaterialMinedTarget = S.TotalMaterialMinedTarget, '
+' T.TotalMaterialMoved = S.TotalMaterialMoved, '
+' T.TotalMaterialMovedTarget = S.TotalMaterialMovedTarget, '
+' T.Payload = S.Payload, '
+' T.PayloadTarget = S.PayloadTarget, '
+' T.deltac = S.deltac, '
+' T.DeltaCTarget = S.DeltaCTarget, '
+' T.IdleTime = S.IdleTime, '
+' T.IdleTimeTarget = S.IdleTimeTarget, '
+' T.Spotting = S.Spotting, '
+' T.SpottingTarget = S.SpottingTarget, '
+' T.Loading = S.Loading, '
+' T.LoadingTarget = S.LoadingTarget, '
+' T.Dumping = S.Dumping, '
+' T.DumpingTarget = S.DumpingTarget, '
+' T.HangTime = S.HangTime, '
+' T.HangTimeTarget = S.HangTimeTarget, '
+' T.EFH = S.EFH, '
+' T.EFHTarget = S.EFHTarget, '
+' T.NumberOfLoads = S.NumberOfLoads, '
+' T.NumberOfLoadsTarget = S.NumberOfLoadsTarget, '
+' T.TonsPerReadyHour = S.TonsPerReadyHour, '
+' T.TonsPerReadyHourTarget = S.TonsPerReadyHourTarget, '
+' T.AssetEfficiency = S.AssetEfficiency, '
+' T.AssetEfficiencyTarget = S.AssetEfficiencyTarget, '
+' T.Availability = S.Availability, '
+' T.AvailabilityTarget = S.AvailabilityTarget '
+' WHEN NOT MATCHED '       
+' THEN INSERT ( '
+' [shiftflag] '
+' ,[siteflag] '
+' ,[shiftid] '
+' ,[shiftindex] '
+' ,[ShovelID] '
+' ,[eqmttype] '
+' ,[Operator] '
+' ,[OperatorId] '
+' ,[OperatorImageURL] '
+' ,[ReasonId] '
+' ,[ReasonDesc] '
+' ,[TotalMaterialMined] '
+' ,[TotalMaterialMinedTarget] '
+' ,[TotalMaterialMoved] '
+' ,[TotalMaterialMovedTarget] '
+' ,[Payload] '
