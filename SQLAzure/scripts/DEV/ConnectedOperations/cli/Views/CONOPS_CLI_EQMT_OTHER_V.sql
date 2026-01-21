CREATE VIEW [cli].[CONOPS_CLI_EQMT_OTHER_V] AS
  
  
  
  
-- SELECT * FROM [cli].[CONOPS_CLI_EQMT_OTHER_V] WITH (NOLOCK) WHERE shiftflag = 'PREV'  ORDER BY shiftflag, siteflag, SupportEquipment  
CREATE VIEW [cli].[CONOPS_CLI_EQMT_OTHER_V]  
AS  
  
WITH SUPEQMT AS (  
 SELECT ShiftIndex,   
  [SHIFTID],  
  FieldId,  
  [EquipmentType],  
  [EquipmentGroup],  
  [FieldUnit],  
  [FieldStatus],  
  [FieldLoc],  
  [FieldCuroper],  
  [FieldReason],  
  [FieldLaststatustime],  
  EqmtUnitId  
 FROM (  
  SELECT  
   tax.[ShiftIndex],  
   tax.[SHIFTID],  
   tax.[FieldId],  
   ( SELECT TOP 1 [DESCRIPTION] FROM [cli].[Enum] WITH (NOLOCK) WHERE [Id] = tax.[FieldEqmttype] ) AS [EquipmentType],  
   ( SELECT TOP 1 [DESCRIPTION] FROM [cli].[Enum] WITH (NOLOCK) WHERE [Id] = tax.[FieldUnit] ) AS [EquipmentGroup],  
   tax.[FieldUnit],  
   tax.[FieldStatus],  
   tax.[FieldLoc],  
   tax.[FieldCuroper],  
   tax.[FieldReason],  
   tax.FieldLaststatustime,  
   enum.idx as EqmtUnitId  
  FROM [cli].[PIT_TRUCK_C] tax WITH (NOLOCK)  
  LEFT JOIN cli.ENUM WITH (NOLOCK)  
  ON tax.FieldUnit = enum.ID  
 ) as tse  
 WHERE tse.EquipmentType NOT LIKE ('CAT 789%')  
  
 UNION  
  
 SELECT   
  pax.[ShiftIndex],  
  pax.[SHIFTID],  
  pax.[FieldId],  
  ( SELECT TOP 1 [DESCRIPTION] FROM [cli].[Enum] WITH (NOLOCK) WHERE [Id] = pax.[FieldEqmttype] ) AS [EquipmentType],  
  ( SELECT TOP 1 [DESCRIPTION] FROM [cli].[Enum] WITH (NOLOCK) WHERE [Id] = pax.[FieldUnit] ) AS [EquipmentGroup],  
  pax.[FieldUnit],  
  pax.[FieldStatus],  
  pax.[FieldLoc],  
  pax.[FieldCuroper],  
  pax.[FieldReason],  
  pax.[FieldLaststatustime],  
  enum.idx as EqmtUnitId  
 FROM [cli].[PIT_AUXEQMT_C] pax WITH (NOLOCK)  
 LEFT JOIN cli.ENUM WITH (NOLOCK)  
 ON pax.FieldUnit = enum.ID  
 WHERE pax.[FieldUnit] <> 227  
),  
  
Detail AS(  
SELECT [shift].shiftflag,  
    [siteflag],  
    [shift].shiftid,  
    [pax].SHIFTINDEX,  
    [pax].SupportEquipmentId,  
    [pax].SupportEquipment,  
    [pax].[StatusCode],  
    [pax].[StatusName],  
    [pax].FieldReason [ReasonId],  
    [r].NAME AS [ReasonDesc],  
    CASE WHEN DATEADD(HH,[shift].current_utc_offset,DATEADD(ss,[pax].FieldLaststatustime,'1970-01-01')) <= [shift].SHIFTSTARTDATETIME  
   THEN [shift].SHIFTSTARTDATETIME  
   ELSE DATEADD(HH,[shift].current_utc_offset,DATEADD(ss,[pax].FieldLaststatustime,'1970-01-01'))   
   END AS [StatusStart],  
    CASE WHEN [shift].SHIFTENDDATETIME <= DATEADD(HH,[shift].current_utc_offset, GETUTCDATE())  
   THEN [shift].SHIFTENDDATETIME   
   ELSE DATEADD(HH,[shift].current_utc_offset, GETUTCDATE())   
   END AS EndTime,  
    CrewName,  
    [pax].[Location],  
    [pax].Region,  
    [pax].[Operator],  
    [pax].[OperatorId],  
    CASE WHEN [OperatorId] IS NULL OR [OperatorId] = -1 THEN NULL  
    ELSE concat([img].Value, RIGHT('0000000000' + [OperatorId], 10),'.jpg') END as OperatorImageURL,  
    [shift].ShiftDuration  
FROM [CLI].[CONOPS_CLI_SHIFT_INFO_V] [shift] WITH (NOLOCK)  
LEFT JOIN (  
 SELECT [pax].SHIFTINDEX,  
     [pax].FieldId AS SupportEquipmentId,  
     [pax].EquipmentGroup AS SupportEquipment,  
     [crew].[DESCRIPTION] AS CrewName,  
     [enumStats].Idx AS [StatusCode],  
     [enumStats].Description AS [StatusName],  
     [pax].FieldLaststatustime,  
     [loc].[FieldId] AS [Location],  
     region.[FieldId] AS Region,  
     [w].FieldId AS [OperatorId],  
     COALESCE([w].FieldName, 'NONE') AS [Operator],  
     [pax].FieldReason  
 FROM SUPEQMT [pax] WITH (NOLOCK)  
 LEFT JOIN [CLI].[enum] [enumStats] WITH (NOLOCK)  
  ON [pax].FieldStatus = [enumStats].Id  
 LEFT JOIN [CLI].[pit_loc] [loc] WITH (NOLOCK)  
  ON [loc].Id = [pax].FieldLoc  
 LEFT JOIN [CLI].[pit_loc] [region] WITH (NOLOCK)  
  ON [loc].FieldRegion = [region].Id  
 LEFT JOIN [CLI].[pit_worker] [w] WITH (NOLOCK)  
  ON [w].Id = [pax].FieldCuroper  
 LEFT JOIN [CLI].[enum] [crew] WITH (NOLOCK)  
  ON [w].FIELDCREW 