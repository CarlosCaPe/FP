
/******************************************************************
* PROCEDURE		: DBO.CONOPS_CLEANUP_PROC
* PURPOSE		: Cleanup CONOPS_CLEANUP_PROC
* NOTES			:         
* CREATED		: ggosal1
* SAMPLE		: EXEC DBO.[CONOPS_CLEANUP_PROC]
* MODIFIED DATE  AUTHOR    DESCRIPTION
*------------------------------------------------------------------
* {22 JUL 2025}  {GGOSAL1}  {INITIAL CREATED}
* {14 NOV 2025}  {GGOSAL1}  {Change to cleanup FUSE table}
*******************************************************************/          
CREATE PROCEDURE [dbo].[CONOPS_CLEANUP_PROC]               
       
AS        
BEGIN        

DECLARE @Last4ShiftID INT;
DECLARE @Last4ShiftIndex INT;
DECLARE @Last4ShiftIndex_CER INT;

SET @Last4ShiftID = (SELECT MIN(SHIFTID) FROM MOR.SHIFT_INFO);
SET @Last4ShiftIndex = (SELECT ShiftIndex - 2 FROM MOR.CONOPS_MOR_SHIFT_INFO_V WHERE SHIFTFLAG = 'PREV');
SET @Last4ShiftIndex_CER = (SELECT ShiftIndex - 20 FROM CER.CONOPS_CER_SHIFT_INFO_V WHERE SHIFTFLAG = 'PREV');

--CLEANUP SNAPSHOT JOB
DELETE FROM dbo.Shift_Line_Graph
WHERE SHIFTID < @Last4ShiftID;

DELETE FROM dbo.Material_Delivered
WHERE SHIFTID < @Last4ShiftID;

DELETE FROM dbo.Material_Mined
WHERE SHIFTID < @Last4ShiftID;

DELETE FROM dbo.Shovel_Equivalent_Flat_Haul
WHERE (SITEFLAG <> 'CER' AND SHIFTINDEX < @Last4ShiftIndex)
OR (SITEFLAG = 'CER' AND SHIFTINDEX < @Last4ShiftIndex_CER);

DELETE FROM dbo.Equivalent_Flat_Haul
WHERE (SITEFLAG <> 'CER' AND SHIFTINDEX < @Last4ShiftIndex)
OR (SITEFLAG = 'CER' AND SHIFTINDEX < @Last4ShiftIndex_CER);

DELETE FROM dbo.CRUSHER_STATS
WHERE (SITEFLAG <> 'CER' AND SHIFTINDEX < @Last4ShiftIndex)
OR (SITEFLAG = 'CER' AND SHIFTINDEX < @Last4ShiftIndex_CER);

--CLEANUP SNOWFLAKE JOB
DELETE FROM dbo.IOS_STOCKPILE_LEVELS_2
WHERE (SITEFLAG <> 'CER' AND SHIFTINDEX < @Last4ShiftIndex)
OR (SITEFLAG = 'CER' AND SHIFTINDEX < @Last4ShiftIndex_CER);

DELETE FROM dbo.CRUSHER_THROUGHPUT_2
WHERE (SITEFLAG <> 'CER' AND SHIFTINDEX < @Last4ShiftIndex)
OR (SITEFLAG = 'CER' AND SHIFTINDEX < @Last4ShiftIndex_CER);

DELETE FROM dbo.CR2_MILL_2
WHERE (SITEFLAG <> 'CER' AND SHIFTINDEX < @Last4ShiftIndex)
OR (SITEFLAG = 'CER' AND SHIFTINDEX < @Last4ShiftIndex_CER);

DELETE FROM dbo.SHOVEL_ELEVATION_2
WHERE (SITE_CODE <> 'CER' AND SHIFTINDEX < @Last4ShiftIndex)
OR (SITE_CODE = 'CER' AND SHIFTINDEX < @Last4ShiftIndex_CER);



END   





