
/******************************************************************    
* PROCEDURE : DBO.[SNAP_CONOPS_FLEET_EQUIPMENT_HOURLY_STATUS]  
* PURPOSE : UPSERT [SNAP_CONOPS_FLEET_EQUIPMENT_HOURLY_STATUS]  
* NOTES     :   
* CREATED : GGOSAL1  
* SAMPLE    : EXEC DBO.[SNAP_CONOPS_FLEET_EQUIPMENT_HOURLY_STATUS] 'BAG'
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {03 JUL 2025}  {GGOSAL1}  {INITIAL CREATED}   
* {10 OCT 2025}  {GGOSAL1}  {Change to BAG2 Equipment Hourly Status} 
*******************************************************************/    
CREATE PROCEDURE [dbo].[SNAP_CONOPS_FLEET_EQUIPMENT_HOURLY_STATUS]
(
@G_SITE VARCHAR(5)
)

WITH EXECUTE AS 'svc_edw_etl'

AS  

IF @G_SITE = 'BAG'
BEGIN

	DELETE FROM BAG2.EQUIPMENT_HOURLY_STATUS_STG;

	INSERT INTO BAG2.EQUIPMENT_HOURLY_STATUS_STG
			   (SHIFTINDEX
				,SHIFTDATE
				,SHIFT_CODE
				,SHIFT
				,CREW
				,SITE_CODE
				,CLIID
				,DDBKEY
				,EQMT
				,UNIT
				,OPERID
				,HOS
				,START_TIME_TS
				,STARTTIME
				,END_TIME_TS
				,ENDTTIME
				,DURATION
				,REASON
				,STATUS
				,CATEGORY
				,COMMENTS
				,VEVENT
				,REASONLINK
				,LOC
				,REGION
				,GPS_X
				,GPS_Y
				,GPS_STATE
				,GPS_HEADING
				,GPS_VELOCITY
				,SYSTEM_VERSION
				,UTC_CREATED_DATE

	)

	SELECT 
		*
	FROM BAG.EQUIPMENT_HOURLY_STATUS;

	EXEC dbo.[UPSERT_CONOPS_EQUIPMENT_HOURLY_STATUS] 'BAG2';

	--Update Table Monitoring
	UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
	SET dw_load_ts = GETUTCDATE()
	WHERE job_name = 'job_conops_equipment_hourly_status_bag'

END






