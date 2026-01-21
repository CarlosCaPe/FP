




/******************************************************************
* PROCEDURE		: DBO.[CONOPS_CLEANUP_SHIFTID_ETL]
* PURPOSE		: Cleanup [CONOPS_CLEANUP_SHIFTID_ETL]
* NOTES			:         
* CREATED		: MFAHMI
* SAMPLE		: EXEC DBO.[CONOPS_CLEANUP_SHIFTID_ETL] 'MOR'
* MODIFIED DATE  AUTHOR    DESCRIPTION
*------------------------------------------------------------------
* {28 DEC 2022}  {MFAHMI}   {INITIAL CREATED}    
* {08 MAY 2023}  {MFAHMI}   {ADD CLEANUP [dbo].[Shovel_Equivalent_Flat_Haul] & [dbo].[Equivalent_Flat_Haul]}     
* {13 JUL 2023}  {MFAHMI}   {ADD CLEANUP [dbo].[HTOS]}  
* {18 JUL 2023}  {GGOSAL1}  {ADD CLEANUP [dbo].[Shift_Line_Graph]}  
* {18 JUL 2023}  {GGOSAL1}  {ADD CLEANUP [dbo].[Crusher_Throughput]}  
* {03 AUG 2023}  {LWASINI}  {ADD CLEANUP [dbo].[Material_Delivered]} 
* {08 AUG 2023}  {LWASINI}  {ADD CLEANUP [dbo].[Material_Mined]} 
* {08 AUG 2023}  {GGOSAL1}  {ADD CLEANUP CLI.SHIFT_GRADE]
* {29 NOV 2023}  {GGOSAL1}  {Change to Last 4 shiftindex} 
* {10 SEP 2024}  {MFAHMI}   {ADD CLEANUP BAG2 TABLE}
*******************************************************************/          
CREATE  PROCEDURE [dbo].[CONOPS_CLEANUP_SHIFTID_ETL]        
(        
@G_SITE  VARCHAR(5)        
      
)        
AS        
BEGIN        
  
EXEC (  
' DECLARE @4_last_shiftid varchar(100) '  
+' DECLARE @4_last_shiftindex VARCHAR(100) '
+' DECLARE @4_last_shiftindex_cer VARCHAR(100) '
+' DECLARE @G_SITE  VARCHAR(5) = ''' +@G_SITE+ ''''  
+' DECLARE @4_last_shiftdate DATETIME2 '
  
+' SET @4_last_shiftid = (select min(shiftid) from ( select distinct top 4 shiftid from ' +@G_SITE+ '.[shift_info] order by shiftid desc) a)'  
+' SET @4_last_shiftdate = (select min(STARTTIME_UTC) from (SELECT top 4 STARTTIME_UTC FROM bag2.SHIFT ORDER BY STARTTIME_UTC DESC) a)'  
+' SET ANSI_WARNINGS OFF; '

+' SELECT @4_last_shiftindex = CASE WHEN siteflag = ''CER'' THEN ShiftIndex - 20 ELSE ShiftIndex - 2 END FROM dbo.SHIFT_INFO_V  WHERE siteflag = @G_SITE AND shiftflag = ''PREV'' '
+' SELECT @4_last_shiftindex_cer = ShiftIndex -20 FROM dbo.SHIFT_INFO_V WHERE siteflag = ''CER'' AND shiftflag = ''PREV'' '

+' SET ANSI_WARNINGS ON; '

+' DECLARE @cleanup varchar(max) '  
+' SET @cleanup = ''delete from @G_SITE.[plan_values] where Formatshiftid < @4_last_shiftid'' '  
  
+' DECLARE @cleanup_saf varchar(max) '  
+' SET @cleanup_saf = ''delete from saf.[plan_values] where CONCAT(RIGHT(REPLACE(CAST(DATEEFFECTIVE AS VARCHAR(10)),''''-'''',''''''''),6),''''00'''',shiftindex) < @4_last_shiftid '' '  
  
+' DECLARE @cleanup_cli varchar(max) '  
+' SET @cleanup_cli = ''delete from cli.[plan_values] where CONCAT(SUBSTRING(ShiftID, 9, 2),SUBSTRING(ShiftID, 4, 2), SUBSTRING(ShiftID, 1, 2), ''''00'''', RIGHT(ShiftID,1)) < @4_last_shiftid'' '  
  
+' SET @cleanup = REPLACE(@cleanup, ''@G_SITE'',''' +@G_SITE+ ''') '  
+' SET @cleanup = REPLACE(@cleanup, ''@4_last_shiftid'', @4_last_shiftid) '  
+' SET @cleanup_saf = REPLACE(@cleanup_saf, ''@4_last_shiftid'', @4_last_shiftid) '  
+' SET @cleanup_cli = REPLACE(@cleanup_cli, ''@4_last_shiftid'', @4_last_shiftid) '  
  
--[shift_info]  
+' delete from ' +@G_SITE+ '.[shift_info]'  
+' where shiftid < @4_last_shiftid'  
  
--[shift_load]  
+' delete from ' +@G_SITE+ '.[shift_load]'  
+' where shiftid < @4_last_shiftid'  
   
--[shift_loc]  
+' delete from ' +@G_SITE+ '.[shift_loc]'  
+' where shiftid < @4_last_shiftid'    
  
--[shift_eqmt]  
+' delete from ' +@G_SITE+ '.[shift_eqmt]'  
+' where shiftid < @4_last_shiftid'    
  
--[shift_dump]  
+' delete from ' +@G_SITE+ '.[shift_dump]'  
+' where shiftid < @4_last_shiftid'    
  
--[EFH_SNAPSHOT_SEQ]  
+' delete from dbo.[EFH_SNAPSHOT_SEQ]'  
+' where shiftid < @4_last_shiftid '   

--[HTOS]  
+' delete from dbo.[HTOS]'  
+' where shiftid < @4_last_shiftid ' 

--[Shovel_Equivalent_Flat_Haul]  
+' delete from [dbo].[Shovel_Equivalent_Flat_Haul] '  
+' where shiftindex < @4_la