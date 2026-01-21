CREATE VIEW [CHI].[CONOPS_CHI_EQMT_OTHER_V] AS
  
  
  
  
-- SELECT * FROM [chi].[CONOPS_CHI_EQMT_OTHER_V] WITH (NOLOCK) WHERE shiftflag = 'CURR'  ORDER BY shiftflag, siteflag, SupportEquipment  
CREATE VIEW [chi].[CONOPS_CHI_EQMT_OTHER_V]  
AS  
  
WITH SUPEQMT AS (  
 SELECT ShiftIndex,   
  FieldId,  
  [EquipmentType],  
  [EquipmentGroup],  
  [FieldUnit],  
  [FieldStatus],  
  [FieldLoc],  
  [FieldCuroper],  
  [FieldReason],  
  [FieldLaststatustime]  
 FROM (  
  SELECT  
   tax.[ShiftIndex],  
   tax.[FieldId],  
   ( SELECT TOP 1 [DESCRIPTION] FROM [chi].[Enum] WITH (NOLOCK) WHERE [Id] = tax.[FieldEqmttype] ) AS [EquipmentType],  
   ( SELECT TOP 1 [DESCRIPTION] FROM [chi].[Enum] WITH (NOLOCK) WHERE [Id] = tax.[FieldUnit] ) AS [EquipmentGroup],  
   tax.[FieldUnit],  
   tax.[FieldStatus],  
   tax.[FieldLoc],  
   tax.[FieldCuroper],  
   tax.[FieldReason],  
   tax.[FieldLaststatustime]  
  FROM [chi].[PIT_TRUCK_C] tax WITH (NOLOCK)  
 ) as tse  
 WHERE tse.EquipmentType NOT LIKE ('CAT 793%')  
  
 UNION  
  
 SELECT   
  pax.[ShiftIndex],  
  pax.[FieldId],  
  ( SELECT TOP 1 [DESCRIPTION] FROM [chi].[Enum] WITH (NOLOCK) WHERE [Id] = pax.[FieldEqmttype] ) AS [EquipmentType],  
  ( SELECT TOP 1 [DESCRIPTION] FROM [chi].[Enum] WITH (NOLOCK) WHERE [Id] = pax.[FieldUnit] ) AS [EquipmentGroup],  
  pax.[FieldUnit],  
  pax.[FieldStatus],  
  pax.[FieldLoc],  
  pax.[FieldCuroper],  
  pax.[FieldReason],  
  pax.[FieldLaststatustime]  
 FROM [chi].[PIT_AUXEQMT_C] pax WITH (NOLOCK)  
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
FROM [CHI].[CONOPS_CHI_SHIFT_INFO_V] [shift] WITH (NOLOCK)  
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
 LEFT JOIN [CHI].[enum] [enumStats] WITH (NOLOCK)  
  ON [pax].FieldStatus = [enumStats].Id  
 LEFT JOIN [CHI].[pit_loc] [loc] WITH (NOLOCK)  
  ON [loc].Id = [pax].FieldLoc  
 LEFT JOIN [CHI].[pit_loc] [region] WITH (NOLOCK)  
  ON [loc].FieldRegion = [region].Id  
 LEFT JOIN [CHI].[pit_worker] [w] WITH (NOLOCK)  
  ON [w].Id = [pax].FieldCuroper  
 LEFT JOIN [CHI].[enum] [crew] WITH (NOLOCK)  
  ON [w].FIELDCREW = [crew].id  
) [pax]  
 ON [pax].SHIFTINDEX = [shift].ShiftIndex  
LEFT JOIN dbo.LOOKUPS [img] WITH (NOLOCK)  
 ON [img].TableType = 'CONF'   
 AND [img].TableCode = 'IMGURL'  
LEFT JOIN [dbo].[LH_REASON] [r] WITH(NOLOCK)  
 ON [r].SITE_CODE = [shift].SITEFLAG  
 