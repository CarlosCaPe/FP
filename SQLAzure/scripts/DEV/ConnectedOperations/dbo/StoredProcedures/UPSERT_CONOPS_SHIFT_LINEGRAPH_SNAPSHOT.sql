




/******************************************************************    
* PROCEDURE : [DBO].[UPSERT_CONOPS_SHIFT_LINEGRAPH_SNAPSHOT]   
* PURPOSE : Upsert [UPSERT_CONOPS_SHIFT_LINEGRAPH_SNAPSHOT]  
* NOTES     :   
* CREATED : lwasini  
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_SHIFT_LINEGRAPH_SNAPSHOT]  
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {17 July 2023}  {lwasini}   {Initial Created}    
* {25 July 2023}  {lwasini}   {Add Total Material Delivered}    
* {08 Aug 2023}  {lwasini}   {Add Total Material Mined}   
* {24 Nov 2023}  {lwasini}   {Add Material Type to Shift Line Graph}
* {05 DEC 2023}  {GGOSAL1}  {Add: update table monitoring}
*******************************************************************/    
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_SHIFT_LINEGRAPH_SNAPSHOT]   
AS  
BEGIN  



INSERT INTO [dbo].[Shift_Line_Graph]

SELECT
siteflag,
shiftid,
shovelid,
TotalMaterialMined,
TotalMaterialMoved,
Mill,
Waste,
CrushLeach,
ROM,
GETUTCDATE() AS UTC_CREATED_DATE
FROM [dbo].[CONOPS_SHIFT_LINEGRAPH_SNAPSHOT_V]
WHERE shovelid IS NOT NULL
AND shiftid IS NOT NULL;

INSERT INTO [dbo].[Material_Delivered]

SELECT
siteflag,
shiftid,
TruckId,
TotalMaterialDelivered,
GETUTCDATE() AS UTC_CREATED_DATE
FROM [dbo].[CONOPS_MATERIAL_DELIVERED_V]
WHERE shiftid IS NOT NULL;


INSERT INTO [dbo].[Material_Mined]

SELECT
siteflag,
shiftid,
shovelid,
TotalMaterialMined,
TotalMaterialMoved,
GETUTCDATE() AS UTC_CREATED_DATE
FROM [dbo].[CONOPS_MATERIAL_MINED_V]
WHERE shiftid IS NOT NULL;


--Update Table Monitoring
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'job_conops_shift_linegraph_snapshot'


END

