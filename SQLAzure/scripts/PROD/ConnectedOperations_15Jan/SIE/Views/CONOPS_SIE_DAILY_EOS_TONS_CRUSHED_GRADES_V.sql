CREATE VIEW [SIE].[CONOPS_SIE_DAILY_EOS_TONS_CRUSHED_GRADES_V] AS
  
  
  
  
  
--SELECT * FROM [sie].[CONOPS_SIE_DAILY_EOS_TONS_CRUSHED_GRADES_V] WHERE SHIFTFLAG = 'CURR'    
CREATE VIEW [sie].[CONOPS_SIE_DAILY_EOS_TONS_CRUSHED_GRADES_V]    
AS    
    
 WITH CrLoc AS (  
     SELECT 'Crusher' CrusherLoc  
     UNION ALL  
     SELECT 'A-SIDE' CrusherLoc  
     UNION ALL  
     SELECT 'B-SIDE' CrusherLoc  
 ),  
  
 CrLocShift AS (  
     SELECT a.SHIFTINDEX,  
      a.SHIFTFLAG,  
      a.SITEFLAG,  
      CrusherLoc  
     FROM CrLoc, [sie].[CONOPS_SIE_EOS_SHIFT_INFO_V] a WITH (NOLOCK)  
 ),  
  
 TonsGrade AS (  
  SELECT [LOAD_SHIFTINDEX] AS [SHIFTINDEX]  
     ,[SITE_CODE]  
     ,CASE WHEN [DUMP_LOC] = 'CR13909O' THEN 'Crusher'  
     ELSE [DUMP_LOC]  
      END [DUMP_LOC]  
     ,SUM((ISNULL([TCU_PCT], 0) * CONVERT(DECIMAL(10), ISNULL([DUMPTONS], 0)))) / SUM([DUMPTONS]) AS [TCU_PCT]  
     ,SUM((ISNULL([TMO_PCT], 0) * CONVERT(DECIMAL(10), ISNULL([DUMPTONS], 0)))) / SUM([DUMPTONS]) AS [TMO_PCT]  
     ,SUM((ISNULL([TCLAY_PCT], 0) * CONVERT(DECIMAL(10), ISNULL([DUMPTONS], 0)))) / SUM([DUMPTONS]) AS [TCLAY_PCT]  
     ,SUM((ISNULL([XCU_PCT], 0) * CONVERT(DECIMAL(10), ISNULL([DUMPTONS], 0)))) / SUM([DUMPTONS]) AS [XCU_PCT]  
     ,SUM((ISNULL([KAOLINITE_PCT], 0) * CONVERT(DECIMAL(10), ISNULL([DUMPTONS], 0)))) / SUM([DUMPTONS]) AS [KAOLINITE_PCT]  
     ,SUM((ISNULL([ASCU_PCT], 0) * CONVERT(DECIMAL(10), ISNULL([DUMPTONS], 0)))) / SUM([DUMPTONS]) AS [ASCU_PCT]  
     ,SUM((ISNULL([SWELLING_CLAY_PCT], 0) * CONVERT(DECIMAL(10), ISNULL([DUMPTONS], 0)))) / SUM([DUMPTONS]) AS [SWELLING_CLAY_PCT]  
     ,SUM((ISNULL([SDR_P80], 0) * CONVERT(DECIMAL(10), ISNULL([DUMPTONS], 0)))) / SUM([DUMPTONS]) AS [SDR_P80]  
  FROM [dbo].[MMT_TRUCKLOAD_C] WITH (NOLOCK)  
  WHERE [SITE_CODE] = 'SIE'  
     AND [DUMP_LOC] in ('CR13909O','A-SIDE','B-SIDE')  
  GROUP BY [LOAD_SHIFTINDEX], [SITE_CODE], [DUMP_LOC]   
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
  
  
