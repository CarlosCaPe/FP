CREATE VIEW [Arch].[CONOPS_ARCH_TRUCK_POPUP_V] AS


CREATE VIEW [Arch].[CONOPS_ARCH_TRUCK_POPUP_V]
AS

WITH TruckTons AS (
    SELECT [shift].shiftflag,
		   [shift].[siteflag],
		   [shift].[shiftid],
		   [TruckId],
		   [Tons]
	FROM [dbo].[SHIFT_INFO_V] [shift] WITH(NOLOCK)
	LEFT JOIN (
		SELECT sd.shiftid,
			   '<SITECODE>' siteflag,
			   t.FieldId AS [TruckId],
			   SUM(sd.FieldLsizetons) AS [Tons]
		FROM ARCH.SHIFT_DUMP sd WITH (NOLOCK) 
		LEFT JOIN ARCH.shift_eqmt t ON t.Id = sd.FieldTruck
		GROUP BY sd.shiftid, t.FieldId
	) [TTons]
	ON [shift].shiftid = [TTons].ShiftId
	   AND [shift].[siteflag] = [TTons].[siteflag]
	WHERE [shift].[siteflag] = '<SITECODE>'
)

SELECT [t].shiftflag,
       [t].siteflag,
	   [t].shiftid,
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
       idletimetarget AS IdleTimeTarget,
       COALESCE(spottime, 0) AS Spotting,
       spottarget AS SpottingTarget,
       COALESCE(loadtime, 0) AS Loading,
       loadtarget AS LoadingTarget,
       COALESCE(DumpingTime, 0) AS Dumping,
       dumpingtarget AS DumpingTarget,
       COALESCE(EFH, 0) AS Efh,
       COALESCE(EFHtarget, 0) AS EfhTarget,
       COALESCE(DumpingAtStockpile, 0) AS [DumpsAtStockpile],
       dumpingatStockpileTarget AS DumpsAtStockpileTarget,
       COALESCE(DumpingAtCrusher, 0) AS DumpsAtCrusher,
       dumpingAtCrusherTarget AS DumpsAtCrusherTarget,
       COALESCE(useOfAvailabilityTarget, 0) AS AvgUseOfAvailibilityTarget,
	   [t].Location
FROM [Arch].[CONOPS_ARCH_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
LEFT JOIN [Arch].[CONOPS_ARCH_TP_AVG_PAYLOAD_V] [payload] WITH (NOLOCK)
ON [t].shiftflag = [payload].shiftflag AND [t].siteflag = [payload].siteflag
   AND [t].TruckID = [payload].TRUCK
LEFT JOIN TruckTons [tt]
ON [t].shiftflag = [tt].shiftflag AND [t].siteflag = [tt].siteflag
   AND [t].TruckID = [tt].TruckId
LEFT JOIN [Arch].[CONOPS_ARCH_TP_DELTA_C_V] [dc] WITH (NOLOCK)
ON [t].shiftflag = [dc].shiftflag AND [t].siteflag = [dc].siteflag
   AND [t].TruckID = [dc].truck

