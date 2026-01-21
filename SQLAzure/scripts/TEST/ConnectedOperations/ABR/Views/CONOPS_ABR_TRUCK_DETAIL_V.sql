CREATE VIEW [ABR].[CONOPS_ABR_TRUCK_DETAIL_V] AS

  
-- SELECT * FROM [abr].[CONOPS_ABR_TRUCK_DETAIL_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'    
CREATE VIEW [ABR].[CONOPS_ABR_TRUCK_DETAIL_V]     
AS    
    
WITH ET AS (    
SELECT    
 shiftindex,    
 eqmtid,    
 eqmttype    
FROM [dbo].[LH_EQUIP_LIST] WITH (NOLOCK)    
WHERE SITE_CODE = 'ELA'    
 AND unit = 'Camion'    
),    
    
Detail AS(    
SELECT [shift].shiftflag,    
    [siteflag],    
    [shift].shiftid,    
    [t].SHIFTINDEX,    
    [t].[TruckID],    
    [et].EQMTTYPE,    
    [t].[StatusCode],    
    [t].[StatusName],    
    [t].FieldReason [ReasonId],    
    [r].NAME AS [ReasonDesc],    
    CASE WHEN DATEADD(HH,[shift].current_utc_offset,DATEADD(ss,[t].FieldLaststatustime,'1970-01-01')) <= [shift].SHIFTSTARTDATETIME    
   THEN [shift].SHIFTSTARTDATETIME    
   ELSE DATEADD(HH,[shift].current_utc_offset,DATEADD(ss,[t].FieldLaststatustime,'1970-01-01'))     
   END AS [StatusStart],    
    CASE WHEN [shift].SHIFTENDDATETIME <= DATEADD(HH,[shift].current_utc_offset, GETUTCDATE())    
   THEN [shift].SHIFTENDDATETIME     
   ELSE DATEADD(HH,[shift].current_utc_offset, GETUTCDATE())     
   END AS EndTime,    
    CrewName,    
    [t].[Location],    
    [t].Region,    
    [t].[Operator],    
    [t].[OperatorId],    
    CASE WHEN [OperatorId] IS NULL OR [OperatorId] = -1 THEN NULL    
    ELSE concat([img].Value, RIGHT('0000000000' + [OperatorId], 10),'.jpg') END as OperatorImageURL,    
    [t].[AssignedShovel],    
    [shift].ShiftDuration,    
    [t].[Destination],    
    [t].FieldXloc,    
    [t].FieldYloc,    
    [t].fieldz,    
    [t].FieldVelocity    
FROM [abr].[CONOPS_ABR_SHIFT_INFO_V] [shift] WITH (NOLOCK)    
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
 FROM [abr].[pit_truck_c] [t] WITH (NOLOCK)    
 LEFT JOIN [abr].[pit_excav_c] [s] WITH (NOLOCK)    
  ON [t].fieldexcav = [s].Id AND [t].SHIFTINDEX = [s].SHIFTINDEX    
 LEFT JOIN [abr].[enum] [enumStats] WITH (NOLOCK)    
  ON [t].FieldStatus = [enumStats].Id    
 LEFT JOIN [abr].[pit_loc] [loc] WITH (NOLOCK)    
  ON [loc].Id = [t].FieldLoc    
 LEFT JOIN [abr].[pit_loc] [region] WITH (NOLOCK)    
  ON [loc].FieldRegion = [region].Id    
 LEFT JOIN [abr].[pit_loc] [des] WITH (NOLOCK)    
  ON [t].FieldLocnext = [des].Id    
 LEFT JOIN [abr].[pit_worker] [w] WITH (NOLOCK)    
  ON [w].Id = [t].FieldCuroper    
 LEFT JOIN [abr].[enum] [crew] WITH (NOLOCK)    
  ON [w].FIELDCREW = [crew].id    
) [t]    
 ON [t].SHIFTINDEX = [shift].ShiftIndex    
LEFT JOIN ET et    
 ON [et].SHIFTINDEX = [shift].ShiftIndex     
 AND [et].EQMTID = [t].TruckID    
LEFT JOIN dbo.LOOKUPS [img] WITH (NOLOCK)    
 ON [img].TableType = 'CONF'     
 AND [img].TableCode = 'IMGURL'    
LEFT JOIN [dbo].[LH_REASON] [r] WITH (NOLOCK)    
 ON [r].SITE_CODE = [shift].SITEFLAG    
 AND [r].SHIFTINDEX = [shift].SHIFTINDEX    
 AND [t].FieldReason = [r].REASON    
    
)    
    
SELECT    
 shiftflag,    
 siteflag,    
 shiftid,    
 SHIFTINDEX,    
 TruckID,    
 EQMTTYPE,    
 StatusCode,    
 StatusName,    
 ReasonId,    
 ReasonDesc,    
 StatusStart,    
 ABS(DATEDIFF(MINUTE, StatusStart, EndTime)) AS TimeInState,    
 CrewName,    
 Location,    
 Region,    
 Operator,    
 OperatorId,    
 OperatorImageURL,    
 AssignedShovel,    
 ShiftDuration,    
 Destination,  