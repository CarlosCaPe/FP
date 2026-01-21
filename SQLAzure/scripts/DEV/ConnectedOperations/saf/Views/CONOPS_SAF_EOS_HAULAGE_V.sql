CREATE VIEW [saf].[CONOPS_SAF_EOS_HAULAGE_V] AS






--SELECT * FROM [SAF].[CONOPS_SAF_EOS_HAULAGE_V] WHERE SHIFTFLAG = 'PREV'
CREATE VIEW [saf].[CONOPS_SAF_EOS_HAULAGE_V]
AS


WITH NrOfLoad AS(
	SELECT 
		shiftflag,
		ROUND(SUM(NumberOfLoads),0) AS NumberOfLoads,
		ROUND(SUM(NumberOfLoadsTarget),0) AS NumberOfLoadsTarget
	FROM [SAF].[CONOPS_SAF_SP_NROFLOAD_V]
	GROUP BY shiftflag
),

EFH AS(
	SELECT DISTINCT
		shiftflag,
		ROUND(AVG(EFH),0) AS Efh,
		ROUND(AVG(EFHShiftTarget),0) AS EfhTarget
	FROM [SAF].[CONOPS_SAF_EFH_V]
	GROUP BY shiftflag
)

SELECT
	siteflag,
	shiftflag,
	KPI,
	ActualValue,
	TargetValue,
	CASE 
		WHEN ActualValue = TargetValue THEN 'Within Plan'
		WHEN ActualValue < TargetValue THEN 'Below Plan'
		ELSE 'Exceeds Plan' 
	END AS Status
FROM(
	SELECT
		[dc].siteflag,
		[dc].shiftflag,
		ISNULL(DeltaC,0) AS DeltaC,
		ISNULL(DeltaCTarget,0) AS DeltaCTarget,
		ISNULL(LoadedTravel,0) AS LoadedTravel,
		ISNULL(LoadedTravelTarget,0) AS LoadedTravelTarget,
		ISNULL(EmptyTravel,0) AS EmptyTravel,
		ISNULL(EmptyTravelTarget,0) AS EmptyTravelTarget,
		ISNULL(DumpingAtCrusher,0) AS DumpingAtCrusher,
		ISNULL(DumpingAtCrusherTarget,0) AS DumpingAtCrusherTarget,
		ISNULL(DumpingAtStockpile,0) AS DumpingAtStockpile,
		ISNULL(DumpingAtStockpileTarget,0) AS DumpingAtStockpileTarget,
		ISNULL(Efh,0) AS Efh,
		ISNULL(EfhTarget,0) AS EfhTarget,
		ISNULL(NumberOfLoads,0) AS NumberOfLoads,
		ISNULL(NumberOfLoadsTarget,0) AS NumberOfLoadsTarget
	FROM [SAF].[CONOPS_SAF_DELTA_C_DETAIL_V] [dc]
	LEFT OUTER JOIN EFH [efh]
		ON [dc].shiftflag = [efh].shiftflag
	LEFT OUTER JOIN NrOfLoad [loads]
		ON [dc].shiftflag = [loads].shiftflag
) a
CROSS APPLY (
VALUES
	('Delta C', DeltaC, DeltaCTarget),
	('Loaded Travel', LoadedTravel, LoadedTravelTarget),
	('Empty Travel', EmptyTravel, EmptyTravelTarget),
	('Dumping at Crusher', DumpingAtCrusher, DumpingAtCrusherTarget),
	('Dumping as Stockpile', DumpingAtStockpile, DumpingAtStockpileTarget),
	('EFH', Efh, EfhTarget),
	('Loads', NumberOfLoads, NumberOfLoadsTarget)
) c (KPI, ActualValue, TargetValue);

