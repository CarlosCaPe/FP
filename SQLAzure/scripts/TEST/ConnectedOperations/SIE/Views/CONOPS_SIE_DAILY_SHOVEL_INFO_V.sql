CREATE VIEW [SIE].[CONOPS_SIE_DAILY_SHOVEL_INFO_V] AS
  
  
  
  
-- SELECT * FROM [sie].[CONOPS_SIE_DAILY_SHOVEL_INFO_V] WITH (NOLOCK)  
CREATE VIEW [sie].[CONOPS_SIE_DAILY_SHOVEL_INFO_V]   
AS  
  
WITH ET AS (  
SELECT  
 shiftindex,  
 eqmtid,  
 eqmttype  
FROM [dbo].[LH_EQUIP_LIST] WITH (NOLOCK)  
WHERE SITE_CODE = 'SIE'  
 AND unit = 'Shovel'  
),  
  
Detail AS(  
SELECT [shift].shiftflag,  
    [siteflag],  
    [shift].shiftid,  
    [s].SHIFTINDEX,  
    [s].[ShovelID],  
    [et].EQMTTYPE,  
    [s].[StatusCode],  
    [s].[StatusName],  
    [s].FieldReason [ReasonId],  
    [r].NAME AS [ReasonDesc],  
    CASE WHEN DATEADD(HH,[shift].current_utc_offset,DATEADD(ss,[s].FieldLaststatustime,'1970-01-01')) <= [shift].SHIFTSTARTDATETIME  
   THEN [shift].SHIFTSTARTDATETIME  
   ELSE DATEADD(HH,[shift].current_utc_offset,DATEADD(ss,[s].FieldLaststatustime,'1970-01-01'))   
   END AS [StatusStart],  
    CASE WHEN [shift].SHIFTENDDATETIME <= DATEADD(HH,[shift].current_utc_offset, GETUTCDATE())  
   THEN [shift].SHIFTENDDATETIME   
   ELSE DATEADD(HH,[shift].current_utc_offset, GETUTCDATE())   
   END AS EndTime,  
    CrewName,  
    [s].[Location],  
    [s].Region,  
    [s].[Operator],  
    [s].[OperatorId],  
    CASE WHEN [OperatorId] IS NULL OR [OperatorId] = -1 THEN NULL  
    ELSE concat([img].Value, RIGHT('0000000000' + [OperatorId], 10),'.jpg') END as OperatorImageURL,  
    [shift].ShiftDuration  
FROM [SIE].[CONOPS_SIE_EOS_SHIFT_INFO_V] [shift] WITH (NOLOCK)  
LEFT JOIN (  
 SELECT [s].SHIFTINDEX,  
     [s].FieldId AS [ShovelID],  
     [crew].[DESCRIPTION] AS CrewName,  
     [enumStats].Idx AS [StatusCode],  
     [enumStats].Description AS [StatusName],  
     [s].FieldLaststatustime,  
     [loc].[FieldId] AS [Location],  
     region.[FieldId] AS Region,  
     [w].FieldId AS [OperatorId],  
     COALESCE([w].FieldName, 'NONE') AS [Operator],  
     [s].FieldReason  
 FROM [SIE].[pit_excav_c] [s] WITH (NOLOCK)  
 LEFT JOIN [SIE].[enum] [enumStats] WITH (NOLOCK)  
  ON [s].FieldStatus = [enumStats].Id  
 LEFT JOIN [SIE].[pit_loc] [loc] WITH (NOLOCK)  
  ON [loc].Id = [s].FieldLoc  
 LEFT JOIN [SIE].[pit_loc] [region] WITH (NOLOCK)  
  ON [loc].FieldRegion = [region].Id  
 LEFT JOIN [SIE].[pit_worker] [w] WITH (NOLOCK)  
  ON [w].Id = [s].FieldCuroper  
 LEFT JOIN [SIE].[enum] [crew] WITH (NOLOCK)  
  ON [w].FIELDCREW = [crew].id  
) [s]  
 ON [s].SHIFTINDEX = [shift].ShiftIndex  
LEFT JOIN ET et  
 ON [et].SHIFTINDEX = [shift].ShiftIndex   
 AND [et].EQMTID = [s].ShovelID  
LEFT JOIN dbo.LOOKUPS [img] WITH (NOLOCK)  
 ON [img].TableType = 'CONF'   
 AND [img].TableCode = 'IMGURL'  
LEFT JOIN [dbo].[LH_REASON] [r] WITH(NOLOCK)  
 ON [r].SITE_CODE = [shift].SITEFLAG  
 AND [r].SHIFTINDEX = [shift].SHIFTINDEX  
 AND [s].FieldReason = [r].REASON  
  
)  
  
SELECT  
 shiftflag,  
 siteflag,  
 shiftid,  
 SHIFTINDEX,  
 ShovelID,  
 EQMTTYPE,  
 StatusCode,  
 StatusName,  
 ReasonId,  
 ReasonDesc,  
 StatusStart,  
 ABS(DATEDIFF(MINUTE, StatusStart, EndTime)) AS Duration,  
 CrewName,  
 Location,  
 Region,  
 Operator,  
 OperatorId,  
 OperatorImageURL,  
 ShiftDuration  
FROM Detail  
  
  
  
  
