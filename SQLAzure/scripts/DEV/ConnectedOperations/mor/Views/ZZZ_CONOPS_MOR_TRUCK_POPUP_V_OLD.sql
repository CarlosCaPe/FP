CREATE VIEW [mor].[ZZZ_CONOPS_MOR_TRUCK_POPUP_V_OLD] AS








-- SELECT * FROM [mor].[CONOPS_MOR_TRUCK_POPUP_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [mor].[CONOPS_MOR_TRUCK_POPUP_V_OLD] 
AS

WITH TruckTons AS (
    SELECT sd.shiftid,
           sd.siteflag,
           t.FieldId AS [TruckId],
           SUM(sd.FieldLsizetons) AS [Tons]
    FROM mor.shift_dump_v sd WITH (NOLOCK)
    LEFT JOIN mor.shift_eqmt t ON t.Id = sd.FieldTruck
    GROUP BY sd.shiftid, t.FieldId,sd.siteflag
)

SELECT [t].shiftflag,
       [t].siteflag,
       [t].TruckID,
       UPPER([t].Operator) Operator,
       [t].OperatorImageURL,
       [t].StatusName,
       [t].ReasonId,
       [t].ReasonDesc,
       COALESCE([payload].AVG_Payload, 0) AS [Payload],
       COALESCE([payload].Target, 0) [PayloadTarget],
       COALESCE([tt].[Tons], 0) [TotalMaterialDelivered],
       NULL [TotalMaterialDeliveredTarget],
       COALESCE(DeltaC, 0) As DeltaC,
       COALESCE(Delta_c_target, 0) AS DeltaCTarget,
       COALESCE(idletime, 0) AS IdleTime,
       COALESCE(idletimetarget, '1.1') AS IdleTimeTarget,
       COALESCE(spottime, 0) AS Spotting,
       COALESCE(spottarget, 0) AS SpottingTarget,
       COALESCE(loadtime, 0) AS Loading,
       COALESCE(loadtarget, 0) AS LoadingTarget,
       COALESCE(DumpingTime, 0) AS Dumping,
       COALESCE(dumpingtarget, 0) AS DumpingTarget,
       COALESCE(EFH, 0) AS Efh,
       COALESCE(EFHtarget, 0) AS EfhTarget,
       COALESCE(DumpingAtStockpile, 0) AS [DumpsAtStockpile],
       COALESCE(dumpingatStockpileTarget, 0) AS DumpsAtStockpileTarget,
       COALESCE(DumpingAtCrusher, 0) AS DumpsAtCrusher,
       COALESCE(dumpingAtCrusherTarget, 0) AS DumpsAtCrusherTarget,
       COALESCE(useOfAvailabilityTarget, 0) * 100 AS AvgUseOfAvailibilityTarget,
	   [t].Location
FROM [mor].[CONOPS_MOR_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
LEFT JOIN [mor].[CONOPS_MOR_TP_AVG_PAYLOAD_V] [payload] WITH (NOLOCK)
ON [t].shiftflag = [payload].shiftflag AND [t].siteflag = [payload].siteflag
   AND [t].TruckID = [payload].TRUCK
LEFT JOIN TruckTons [tt]
ON [t].shiftid = [tt].shiftid AND [t].siteflag = [tt].siteflag
   AND [t].TruckID = [tt].TruckId
LEFT JOIN [mor].[CONOPS_MOR_TP_DELTA_C_V] [dc] WITH (NOLOCK)
ON [t].shiftflag = [dc].shiftflag AND [t].siteflag = [dc].siteflag
   AND [t].TruckID = [dc].truck

