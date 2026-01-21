




/******************************************************************
* PROCEDURE : DBO.[UPSERT_CONOPS_TRUCK_POPUP]
* PURPOSE : UPSERT [UPSERT_CONOPS_TRUCK_POPUP]
* NOTES : 
* CREATED : GGOSAL1
* SAMPLE: EXEC DBO.[UPSERT_CONOPS_TRUCK_POPUP] 'SIE'
* MODIFIED DATE		AUTHOR			DESCRIPTION
*------------------------------------------------------------------
* {15 APR 2024}		{GGOSAL1}		{INITIAL CREATED}
*******************************************************************/
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_TRUCK_POPUP]    
(      
@G_SITE VARCHAR(5)      
)      
AS      
BEGIN
--DECLARE @G_SITE_ALIAS VARCHAR(5)

--SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' ELSE @G_SITE END

EXEC       
( 

' DELETE FROM ' +@G_SITE+ '.CONOPS_' +@G_SITE+ '_TRUCK_POPUP_STG ; '

+' INSERT INTO ' +@G_SITE+ '.CONOPS_' +@G_SITE+ '_TRUCK_POPUP_STG '
+' SELECT * FROM ' +@G_SITE+ '.CONOPS_' +@G_SITE+ '_TRUCK_POPUP_V; '

+'MERGE ' +@G_SITE+ '.CONOPS_' +@G_SITE+ '_TRUCK_POPUP AS T '      
+' USING (SELECT '     
+' [shiftflag] '
+' ,[siteflag] '
+' ,[shiftid] '
+' ,[shiftindex] '
+' ,[TruckID] '
+' ,[eqmttype] '
+' ,[Operator] '
+' ,[OperatorId] '
+' ,[OperatorImageURL] '
+' ,[StatusName] '
+' ,[ReasonId] '
+' ,[ReasonDesc] '
+' ,[Payload] '
+' ,[PayloadTarget] '
+' ,[TotalMaterialDelivered] '
+' ,[TotalMaterialDeliveredTarget] '
+' ,[DeltaC] '
+' ,[DeltaCTarget] '
+' ,[IdleTime] '
+' ,[IdleTimeTarget] '
+' ,[Spotting] '
+' ,[SpottingTarget] '
+' ,[Loading] '
+' ,[LoadingTarget] '
+' ,[Dumping] '
+' ,[DumpingTarget] '
+' ,[Efh] '
+' ,[EfhTarget] '
+' ,[DumpsAtStockpile] '
+' ,[DumpsAtStockpileTarget] '
+' ,[DumpsAtCrusher] '
+' ,[DumpsAtCrusherTarget] '
+' ,[LoadedTravel] '
+' ,[LoadedTravelTarget] '
+' ,[EmptyTravel] '
+' ,[EmptyTravelTarget] '
+' ,[AvgUseOfAvailibility] '
+' ,[AvgUseOfAvailibilityTarget] '
+' ,[Availability] '
+' ,[AvailabilityTarget] '
+' ,[Location] '
+' FROM ' +@G_SITE+ '.CONOPS_' +@G_SITE+ '_TRUCK_POPUP_STG) AS S '      
+' ON (T.SITEFLAG = S.SITEFLAG AND T.SHIFTID = S.SHIFTID AND T.TruckID = S.TruckID) '       
+' WHEN MATCHED '       
+' THEN UPDATE SET '       
+' T.shiftflag = S.shiftflag, '
+' T.shiftindex = S.shiftindex, '
+' T.eqmttype = S.eqmttype, '
+' T.Operator = S.Operator, '
+' T.OperatorId = S.OperatorId, '
+' T.OperatorImageURL = S.OperatorImageURL, '
+' T.StatusName = S.StatusName, '
+' T.ReasonId = S.ReasonId, '
+' T.ReasonDesc = S.ReasonDesc, '
+' T.Payload = S.Payload, '
+' T.PayloadTarget = S.PayloadTarget, '
+' T.TotalMaterialDelivered = S.TotalMaterialDelivered, '
+' T.TotalMaterialDeliveredTarget = S.TotalMaterialDeliveredTarget, '
+' T.DeltaC = S.DeltaC, '
+' T.DeltaCTarget = S.DeltaCTarget, '
+' T.IdleTime = S.IdleTime, '
+' T.IdleTimeTarget = S.IdleTimeTarget, '
+' T.Spotting = S.Spotting, '
+' T.SpottingTarget = S.SpottingTarget, '
+' T.Loading = S.Loading, '
+' T.LoadingTarget = S.LoadingTarget, '
+' T.Dumping = S.Dumping, '
+' T.DumpingTarget = S.DumpingTarget, '
+' T.Efh = S.Efh, '
+' T.EfhTarget = S.EfhTarget, '
+' T.DumpsAtStockpile = S.DumpsAtStockpile, '
+' T.DumpsAtStockpileTarget = S.DumpsAtStockpileTarget, '
+' T.DumpsAtCrusher = S.DumpsAtCrusher, '
+' T.DumpsAtCrusherTarget = S.DumpsAtCrusherTarget, '
+' T.LoadedTravel = S.LoadedTravel, '
+' T.LoadedTravelTarget = S.LoadedTravelTarget, '
+' T.EmptyTravel = S.EmptyTravel, '
+' T.EmptyTravelTarget = S.EmptyTravelTarget, '
+' T.AvgUseOfAvailibility = S.AvgUseOfAvailibility, '
+' T.AvgUseOfAvailibilityTarget = S.AvgUseOfAvailibilityTarget, '
+' T.Availability = S.Availability, '
+' T.AvailabilityTarget = S.AvailabilityTarget, '
+' T.Location = S.Location '
+' WHEN NOT MATCHED '       
+' THEN INSERT ( '
+' [shiftflag] '
+' ,[siteflag] '
+' ,[shiftid] '
+' ,[shiftindex] '
+' ,[TruckID] '
+' ,[eqmttype] '
+' ,[Operator] '
+' ,[OperatorId] '
+' ,[OperatorImageURL] '
+' ,[StatusName] '
+' ,[ReasonId] '
+' ,[Reaso