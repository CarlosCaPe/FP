CREATE VIEW [mor].[CONOPS_MOR_DAILY_EOS_TONS_CRUSHED_GRADES_V] AS
  
  
--SELECT * FROM [mor].[CONOPS_MOR_DAILY_EOS_TONS_CRUSHED_GRADES_V] WHERE SHIFTFLAG = 'CURR'    
CREATE VIEW [mor].[CONOPS_MOR_DAILY_EOS_TONS_CRUSHED_GRADES_V]    
AS    
    
 WITH CrLoc AS (  
     SELECT 'Crusher 2' CrusherLoc  
     UNION ALL  
     SELECT 'Crusher 3' CrusherLoc  
 ),  
  
 CrLocShift AS (  
     SELECT a.SHIFTINDEX,  
      a.SHIFTFLAG,  
      a.SITEFLAG,  
      CrusherLoc  
     FROM CrLoc, [mor].[CONOPS_MOR_EOS_SHIFT_INFO_V] a WITH (NOLOCK)  
 ),  
  
 TonsGrade AS (  
  SELECT [SHIFTINDEX]  
     ,[SITE_CODE]  
     ,[DUMP_LOC]  
     ,SUM((ISNULL([TCU_PCT], 0) * CONVERT(DECIMAL(10), ISNULL([DUMPTONS], 0)))) / SUM([DUMPTONS]) AS [TCU_PCT]  
     ,SUM((ISNULL([TMO_PCT], 0) * CONVERT(DECIMAL(10), ISNULL([DUMPTONS], 0)))) / SUM([DUMPTONS]) AS [TMO_PCT]  
     ,SUM((ISNULL([TCLAY_PCT], 0) * CONVERT(DECIMAL(10), ISNULL([DUMPTONS], 0)))) / SUM([DUMPTONS]) AS [TCLAY_PCT]  
     ,SUM((ISNULL([XCU_PCT], 0) * CONVERT(DECIMAL(10), ISNULL([DUMPTONS], 0)))) / SUM([DUMPTONS]) AS [XCU_PCT]  
     ,SUM((ISNULL([KAOLINITE_PCT], 0) * CONVERT(DECIMAL(10), ISNULL([DUMPTONS], 0)))) / SUM([DUMPTONS]) AS [KAOLINITE_PCT]  
     ,SUM((ISNULL([ASCU_PCT], 0) * CONVERT(DECIMAL(10), ISNULL([DUMPTONS], 0)))) / COUNT([DUMPTONS]) AS [ASCU_PCT]  
     ,SUM((ISNULL([SWELLING_CLAY_PCT], 0) * CONVERT(DECIMAL(10), ISNULL([DUMPTONS], 0)))) / SUM([DUMPTONS]) AS [SWELLING_CLAY_PCT]  
     ,SUM((ISNULL([SDR_P80], 0) * CONVERT(DECIMAL(10), ISNULL([DUMPTONS], 0)))) / SUM([DUMPTONS]) AS [SDR_P80]  
  FROM (  
   SELECT [LOAD_SHIFTINDEX] AS [SHIFTINDEX]  
      ,[SITE_CODE]  
      ,CASE WHEN [DUMP_LOC] IN ('C2MIL', 'C2MFL', '849-MFL') THEN 'Crusher 2'  
      WHEN [DUMP_LOC] IN ('C3MIL', 'C3MFL', '859-MILL') THEN 'Crusher 3'  
       END [DUMP_LOC]  
      ,[TCU_PCT]  
      ,[TMO_PCT]  
      ,[TCLAY_PCT]  
      ,[XCU_PCT]  
      ,[KAOLINITE_PCT]  
      ,[ASCU_PCT]  
      ,[SWELLING_CLAY_PCT]  
      ,[SDR_P80]  
      ,[DUMPTONS]  
   FROM [dbo].[MMT_TRUCKLOAD_C] WITH (NOLOCK)  
   WHERE [SITE_CODE] = 'MOR'  
      AND [DUMP_LOC] in ('C2MIL','C2MFL','849-MFL', 'C3MIL','C3MFL','859-MILL')  
  ) [a]  
  GROUP BY [SHIFTINDEX], [SITE_CODE], [DUMP_LOC]   
 )  
  
 SELECT cl.siteflag,  
     cl.SHIFTFLAG,  
     cl.SHIFTINDEX,  
     cl.CrusherLoc,  
     [TCU_PCT],  
     [TMO_PCT],  
     [TCLAY_PCT],  
     [XCU_PCT],  
     [KAOLINITE_PCT],  
     [ASCU_PCT],  
     [SWELLING_CLAY_PCT],  
     [SDR_P80]  
 FROM CrLocShift cl  
 LEFT JOIN TonsGrade tg  
 ON cl.SHIFTINDEX = tg.SHIFTINDEX  
    AND cl.CrusherLoc = tg.DUMP_LOC  
  
  
