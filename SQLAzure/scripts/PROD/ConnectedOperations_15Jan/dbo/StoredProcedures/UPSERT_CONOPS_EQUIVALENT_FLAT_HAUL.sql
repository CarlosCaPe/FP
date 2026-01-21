







/******************************************************************    
* PROCEDURE : [DBO].[UPSERT_CONOPS_EQUIVALENT_FLAT_HAUL]   
* PURPOSE : Upsert [UPSERT_CONOPS_EQUIVALENT_FLAT_HAUL]  
* NOTES     :   
* CREATED : lwasini  
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_EQUIVALENT_FLAT_HAUL]  
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {26 Apr 2023}  {lwasini}   {Initial Created}    
* {05 Dec 2023}  {ggosal1}   {Add: update table monitoring} 
* {25 Jan 2024}  {ggosal1}   {Update time to UTC} 
* {01 Apr 2024}  {ggosal1}   {Add filter WHERE EXCAV IS NOT NULL} 
* {15 Apr 2024}  {ggosal1}   {Add Truck & Shovel Popup materialization} 
*******************************************************************/    
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_EQUIVALENT_FLAT_HAUL]   
AS  
BEGIN  



INSERT INTO [dbo].[Shovel_Equivalent_Flat_Haul] 

SELECT
a.siteflag,
a.shiftindex,
b.excav,
b.EFH,
GETUTCDATE() AS [UTC_CREATED_DATE]
FROM (

SELECT
site_code as siteflag,
max(shiftindex) shiftindex
FROM dbo.delta_c 
group by site_code) a

LEFT JOIN (
SELECT 
site_code,
shiftindex,
excav,
avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS EFH
FROM dbo.delta_c with (nolock)
group by shiftindex,site_code,excav) b
ON a.siteflag = b.SITE_CODE AND a.shiftindex = b.SHIFTINDEX
WHERE excav IS NOT NULL;

INSERT INTO [dbo].[Equivalent_Flat_Haul] 

SELECT
a.siteflag,
a.shiftindex,
b.EFH,
GETUTCDATE() AS [UTC_CREATED_DATE]
FROM (

SELECT
site_code as siteflag,
max(shiftindex) shiftindex
FROM dbo.delta_c 
group by site_code) a

LEFT JOIN (
SELECT 
site_code,
shiftindex,
avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS EFH
FROM dbo.delta_c with (nolock)
group by shiftindex,site_code) b
ON a.siteflag = b.SITE_CODE AND a.shiftindex = b.SHIFTINDEX;

--Update Table Monitoring
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'job_conops_equivalent_flat_haul';

--Truck Popup
EXEC DBO.[UPSERT_CONOPS_TRUCK_POPUP] 'BAG';
EXEC DBO.[UPSERT_CONOPS_TRUCK_POPUP] 'CER';
EXEC DBO.[UPSERT_CONOPS_TRUCK_POPUP] 'CHI';
EXEC DBO.[UPSERT_CONOPS_TRUCK_POPUP] 'CLI';
EXEC DBO.[UPSERT_CONOPS_TRUCK_POPUP] 'MOR';
EXEC DBO.[UPSERT_CONOPS_TRUCK_POPUP] 'SAF';
EXEC DBO.[UPSERT_CONOPS_TRUCK_POPUP] 'SIE';
EXEC DBO.[UPSERT_CONOPS_TRUCK_POPUP] 'ABR';
EXEC DBO.[UPSERT_CONOPS_TRUCK_POPUP] 'TYR';

--Update Table Monitoring Truck Popup
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'job_conops_truck_popup';

--Shovel Popup
EXEC DBO.[UPSERT_CONOPS_SHOVEL_POPUP] 'BAG';
EXEC DBO.[UPSERT_CONOPS_SHOVEL_POPUP] 'CER';
EXEC DBO.[UPSERT_CONOPS_SHOVEL_POPUP] 'CHI';
EXEC DBO.[UPSERT_CONOPS_SHOVEL_POPUP] 'CLI';
EXEC DBO.[UPSERT_CONOPS_SHOVEL_POPUP] 'MOR';
EXEC DBO.[UPSERT_CONOPS_SHOVEL_POPUP] 'SAF';
EXEC DBO.[UPSERT_CONOPS_SHOVEL_POPUP] 'SIE';
EXEC DBO.[UPSERT_CONOPS_SHOVEL_POPUP] 'ABR';
EXEC DBO.[UPSERT_CONOPS_SHOVEL_POPUP] 'TYR';

--Update Table Monitoring Shovel Popup
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'job_conops_shovel_popup';


END







