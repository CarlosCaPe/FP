CREATE VIEW [cer].[CONOPS_CER_TRUCK_DETAIL_V] AS
  
  
  
  
-- SELECT * FROM [cer].[CONOPS_CER_TRUCK_DETAIL_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR' ORDER BY TruckID  
CREATE VIEW [cer].[CONOPS_CER_TRUCK_DETAIL_V]  
AS  
  
WITH ET AS (  
SELECT  
 shiftindex,  
 eqmtid,  
 eqmttype  
FROM [dbo].[LH_EQUIP_LIST] WITH (NOLOCK)  
WHERE SITE_CODE = 'CER'  
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
    [t].[PersonnelId],  
    CASE WHEN [OperatorId] IS NULL OR [OperatorId] = -1 THEN NULL  
    ELSE concat([img].Value, RIGHT('000000' + [PersonnelId], 10),'.jpg') END as OperatorImageURL,  
    [t].[AssignedShovel],  
    [shift].ShiftDuration,  
    [t].[Destination],  
    [t].FieldXloc,  
    [t].FieldYloc,  
    [t].fieldz,  
    [t].FieldVelocity  
FROM [CER].[CONOPS_CER_SHIFT_INFO_V] [shift] WITH (NOLOCK)  
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
     [opm].[personnel_id] AS PersonnelId,  
     [des].[FieldId] AS [Destination],  
     [t].FieldXloc,  
     [t].FieldYloc,  
     [t].fieldz,  
     [t].FieldVelocity  
 FROM [CER].[pit_truck_c] [t] WITH (NOLOCK)  
 LEFT JOIN [CER].[pit_excav_c] [s] WITH (NOLOCK)  
  ON [t].fieldexcav = [s].Id AND [t].SHIFTINDEX = [s].SHIFTINDEX  
 LEFT JOIN [CER].[enum] [enumStats] WITH (NOLOCK)  
  ON [t].FieldStatus = [enumStats].enum_id  
 LEFT JOIN [CER].[pit_loc] [loc] WITH (NOLOCK)  
  ON [loc].Id = [t].FieldLoc  
 LEFT JOIN [CER].[pit_loc] [region] WITH (NOLOCK)  
  ON [loc].FieldRegion = [region].Id  
 LEFT JOIN [CER].[pit_loc] [des] WITH (NOLOCK)  
  ON [t].FieldLocnext = [des].Id  
 LEFT JOIN [CER].[pit_worker] [w] WITH (NOLOCK)  
  ON [w].Id = [t].FieldCuroper  
 LEFT JOIN [cer].[operator_personnel_map] [opm] WITH (NOLOCK)  
  ON [w].[FieldId] = [opm].[operator_id]  
 LEFT JOIN [CER].[enum] [crew] WITH (NOLOCK)  
  ON [w].FIELDCREW = [crew].enum_id  
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
 PersonnelId,  
 OperatorImageURL,  
 AssignedShovel,  
 ShiftDuration,  
 Destination,  
