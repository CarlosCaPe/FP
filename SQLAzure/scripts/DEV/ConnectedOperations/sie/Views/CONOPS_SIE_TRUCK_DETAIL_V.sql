CREATE VIEW [sie].[CONOPS_SIE_TRUCK_DETAIL_V] AS







-- SELECT * FROM [sie].[CONOPS_SIE_TRUCK_DETAIL_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR' ORDER BY TruckID
CREATE VIEW [sie].[CONOPS_SIE_TRUCK_DETAIL_V] 
AS

WITH ae AS (
	SELECT shiftid
		   , eqmt
		   , reasonidx
		   , reasons
		   , TimeInState
	FROM (
		SELECT shiftid,
			   eqmt,
			   reasonidx,
			   reasons,
			   duration/60.0 AS TimeInState,
			   ROW_NUMBER() OVER (PARTITION BY shiftid, eqmt  ORDER BY startdatetime DESC) AS rn
		FROM [SIE].[asset_efficiency] WITH (NOLOCK)
	) [a]
	WHERE rn = 1
),

ET AS (
SELECT
shiftindex,
eqmtid,
eqmttype
FROM [dbo].[LH_EQUIP_LIST] WITH (NOLOCK)
WHERE SITE_CODE = 'SIE'
AND unit = 'Truck')

SELECT [shift].shiftflag,
	   [siteflag],
	   [shift].shiftid,
	   [t].SHIFTINDEX,
	   [t].[TruckID],
	   [et].[eqmttype],
	   [t].[StatusCode],
	   [t].[StatusName],
	   [t].FieldReason [ReasonId],
	   [ae].reasons [ReasonDesc],
	   --CAST([t].FieldReason as varchar(10)) + ':' + [ae].reasons [StatusDesc],
	   DATEADD(HH,[shift].current_utc_offset,DATEADD(ss,[t].FieldLaststatustime,'1970-01-01')) AS [StatusStart],
	   TimeInState,
	   CrewName,
	   [t].[Location],
	   [t].Region,
	   [t].[Operator],
	   [t].[OperatorId],
	   CASE WHEN [OperatorId] IS NULL OR [OperatorId] = -1 THEN NULL
	   ELSE concat([img].Value,
				   RIGHT('0000000000' + [OperatorId], 10),'.jpg') END as OperatorImageURL,
	   [t].[AssignedShovel],
	   [shift].ShiftDuration,
	   [t].[Destination],
	   [t].FieldXloc,
	   [t].FieldYloc,
	   [t].fieldz,
	   [t].FieldVelocity
FROM [SIE].[CONOPS_SIE_SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN (
	SELECT [t].SHIFTINDEX,
		   [t].FieldId AS [TruckID],
		   [crew].[DESCRIPTION] AS CrewName,
		   [enumStats].Idx AS [StatusCode],
		   [enumStats].Description AS [StatusName],
		   [t].FieldLaststatustime,
		   [loc].[FieldId] AS [Location],
		   region.[FieldId] AS Region,
		   [w].FieldId AS [OperatorId],
		   COALESCE([w].FieldName, 'NONE') AS [Operator],
		   [s].FieldId [AssignedShovel],
		   [t].FieldReason,
		   [des].[FieldId] AS [Destination],
		   [t].FieldXloc,
		   [t].FieldYloc,
		   [t].fieldz,
		   [t].FieldVelocity
	FROM [SIE].[pit_truck_c] [t] WITH (NOLOCK)
	LEFT JOIN [SIE].[pit_excav_c] [s] WITH (NOLOCK)
	ON [t].fieldexcav = [s].Id AND [t].SHIFTINDEX = [s].SHIFTINDEX
	LEFT JOIN [SIE].[enum] [enumStats] WITH (NOLOCK)
	ON [t].FieldStatus = [enumStats].Id
	LEFT JOIN [SIE].[pit_loc] [loc] WITH (NOLOCK)
	ON [loc].Id = [t].FieldLoc
	LEFT JOIN [SIE].[pit_loc] [region] WITH (NOLOCK)
	ON [loc].FieldRegion = [region].Id
	LEFT JOIN [SIE].[pit_loc] [des] WITH (NOLOCK)
	ON [t].FieldLocnext = [des].Id
	LEFT JOIN [SIE].[pit_worker] [w] WITH (NOLOCK)
	ON [w].Id = [t].FieldCuroper
	LEFT JOIN [sie].[enum] [crew] WITH (NOLOCK)
	ON [w].FIELDCREW = [crew].id
) [t]
on [t].SHIFTINDEX = [shift].ShiftIndex
LEFT JOIN [ae] 
ON [shift].shiftid = [ae].shiftid AND [t].TruckID = [ae].eqmt 
   AND [t].FieldReason = [ae].reasonidx
LEFT JOIN ET et
ON [et].SHIFTINDEX = [shift].ShiftIndex AND [et].EQMTID = [t].TruckID
LEFT JOIN dbo.LOOKUPS [img] WITH (NOLOCK)
ON [img].TableType = 'CONF' AND [img].TableCode = 'IMGURL'





