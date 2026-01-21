CREATE VIEW [dbo].[CONOPS_DB_DRILL_ASSET_EFFICIENCY_V] AS




--select * from [dbo].[CONOPS_DB_DRILL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
CREATE VIEW [dbo].[CONOPS_DB_DRILL_ASSET_EFFICIENCY_V]
AS

SELECT [shiftflag],
	   [siteflag],
	   [Hos],
	   [Hr],
	   AVG(AE) [AE],
	   AVG([Avail]) [Avail],
	   AVG([UofA]) [UofA],
	   0 [AETarget],
	   0 [AvailTarget],
	   0 [UofATarget]
FROM [mor].[CONOPS_MOR_HOURLY_DRILL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
WHERE [siteflag] = 'MOR'
GROUP BY [shiftflag], [siteflag], [Hos], [Hr]

UNION ALL

SELECT [shiftflag],
	   a.[siteflag],
	   [Hos],
	   [Hr],
	   AVG(AE) [AE],
	   AVG([Avail]) [Avail],
	   AVG([UofA]) [UofA],
	   [t].DRILLASSETEFFICIENCY [AETarget],
	   [t].DRILLAVAILABILITY [AvailTarget],
	   [t].DRILLUTILIZATION [UofATarget]
FROM [bag].[CONOPS_BAG_HOURLY_DRILL_ASSET_EFFICIENCY_V] [a] WITH (NOLOCK)
LEFT JOIN [bag].[CONOPS_BAG_DB_DRILL_ASSET_EFFICIENCY_TARGET_V] [t]
ON LEFT([a].shiftid, 4) = [t].ShiftId
WHERE a.[siteflag] = 'BAG'
GROUP BY [shiftflag], a.[siteflag], [Hos], [Hr],
		 [t].DRILLASSETEFFICIENCY, [t].DRILLAVAILABILITY, [t].DRILLUTILIZATION

UNION ALL

SELECT [shiftflag],
	   a.[siteflag],
	   [Hos],
	   [Hr],
	   AVG(AE) [AE],
	   AVG([Avail]) [Avail],
	   AVG([UofA]) [UofA],
	   [t].DRILLASSETEFFICIENCY [AETarget],
	   [t].DRILLAVAILABILITY [AvailTarget],
	   [t].DRILLUTILIZATION [UofATarget]
FROM [saf].[CONOPS_SAF_HOURLY_DRILL_ASSET_EFFICIENCY_V] [a] WITH (NOLOCK)
LEFT JOIN [saf].[CONOPS_SAF_DB_DRILL_ASSET_EFFICIENCY_TARGET_V] [t]
ON [a].shiftid = [t].ShiftId
WHERE a.[siteflag] = 'SAF'
GROUP BY [shiftflag], a.[siteflag], [Hos], [Hr],
		 [t].DRILLASSETEFFICIENCY, [t].DRILLAVAILABILITY, [t].DRILLUTILIZATION

UNION ALL

SELECT [shiftflag],
	   [a].[siteflag],
	   [Hos],
	   [Hr],
	   AVG(AE) [AE],
	   AVG([Avail]) [Avail],
	   AVG([UofA]) [UofA],
	   [t].DRILLASSETEFFICIENCY [AETarget],
	   [t].DRILLAVAILABILITY [AvailTarget],
	   [t].DRILLUTILIZATION [UofATarget]
FROM [sie].[CONOPS_SIE_HOURLY_DRILL_ASSET_EFFICIENCY_V] [a] WITH (NOLOCK)
LEFT JOIN [sie].[CONOPS_SIE_DB_DRILL_ASSET_EFFICIENCY_TARGET_V] [t]
ON LEFT([a].shiftid, 4) = [t].ShiftId
WHERE [a].[siteflag] = 'SIE'
GROUP BY [shiftflag], [a].[siteflag], [Hos], [Hr],
		 [t].DRILLASSETEFFICIENCY, [t].DRILLAVAILABILITY, [t].DRILLUTILIZATION

UNION ALL

SELECT [shiftflag],
	   [a].[siteflag],
	   [Hos],
	   [Hr],
	   AVG(AE) [AE],
	   AVG([Avail]) [Avail],
	   AVG([UofA]) [UofA],
	   [t].DRILLASSETEFFICIENCY [AETarget],
	   [t].DRILLAVAILABILITY [AvailTarget],
	   [t].DRILLUTILIZATION [UofATarget]
FROM [cer].[CONOPS_CER_HOURLY_DRILL_ASSET_EFFICIENCY_V] [a] WITH (NOLOCK)
LEFT JOIN [cer].[CONOPS_CER_DB_DRILL_ASSET_EFFICIENCY_TARGET_V] [t]
ON LEFT([a].shiftid, 4) = [t].ShiftId
WHERE [a].[siteflag] = 'CER'
GROUP BY [shiftflag], [a].[siteflag], [Hos], [Hr],
		 [t].DRILLASSETEFFICIENCY, [t].DRILLAVAILABILITY, [t].DRILLUTILIZATION

UNION ALL

SELECT [shiftflag],
	   [siteflag],
	   [Hos],
	   [Hr],
	   AVG(AE) [AE],
	   AVG([Avail]) [Avail],
	   AVG([UofA]) [UofA],
	   0 [AETarget],
	   0 [AvailTarget],
	   0 [UofATarget]
FROM [cli].[CONOPS_CLI_HOURLY_DRILL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
WHERE [siteflag] = 'CMX'
GROUP BY [shiftflag], [siteflag], [Hos], [Hr]

UNION ALL

SELECT [shiftflag],
	   [a].[siteflag],
	   [Hos],
	   [Hr],
	   AVG(AE) [AE],
	   AVG([Avail]) [Avail],
	   AVG([UofA]) [UofA],
	   [t].DRILLASSETEFFICIENCY [AETarget],
	   [t].DRILLAVAILABILITY [AvailTarget],
	   [t].DRILLUTILIZATION [UofATarget]
FROM [chi].[CONOPS_CHI_HOURLY_DRILL_ASSET_EFFICIENCY_V] [a] WITH (NOLOCK)
LEFT JOIN [chi].[CONOPS_CHI_DB_DRILL_ASSET_EFFICIENCY_TARGET_V] [t]
ON LEFT([a].shiftid, 4) = [t].ShiftId
WHERE [a].[siteflag] = 'CHI'
GROUP BY [shiftflag], [a].[siteflag], [Hos], [Hr],
		 [t].DRILLASSETEFFICIENCY, [t].DRILLAVAILABILITY, [t].DRILLUTILIZATION


