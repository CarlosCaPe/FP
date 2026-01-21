


/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_CRUSHER_STATUS]
* PURPOSE	: Upsert [UPSERT_CONOPS_CRUSHER_STATUS]
* NOTES     : 
* CREATED	: ggosal1
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_CRUSHER_STATUS] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {23 SEP 2024}		{ggosal1}			{Initial Created}  
*******************************************************************/  
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_CRUSHER_STATUS]
AS
BEGIN

DELETE FROM dbo.CRUSHER_STATUS

INSERT INTO dbo.CRUSHER_STATUS
SELECT [SITE_CODE]
      ,[HIERARCHY_ID]
      ,[DOWNTIME_ID]
      ,[PLANT_AREA_NAME]
      ,[CALENDAR_DATE]
      ,[PRODCTN_DATE]
      ,[SHIFT_INDICATOR]
      ,[START_TS]
      ,[START_DATE]
      ,[START_TIME]
      ,[STOP_TS]
      ,[STOP_DATE]
      ,[STOP_TIME]
      ,[DOWNTIME_DURATION]
      ,[ACT_MINS]
      ,[EFF_MINS]
      ,[FAILURE_CODE_ID]
      ,[ORIG_CODE]
      ,[EQUIP_NO_ID]
      ,[DOWNTIME_TYPE]
      ,[DOWNTIME_CAT]
      ,[PROBLEM_ID]
      ,[CAUSE_NAME]
      ,[EQMT]
      ,[EQUIP_DESC]
      ,[SAP_ID]
      ,[EQUIP_FUNC_LOC]
      ,[DOWNTIME_EVENT_PARENT_INDICATO]
      ,[FURTHER_WORK_ORDER_CODE]
      ,[GENRT_WORK_ORDER_CODE]
      ,[WORK_ORDER_NO]
      ,[WORK_ORDER_STATUS]
      ,[WORK_ORDER_COMMENT]
      ,[EQUIP_ALARM]
      ,[ALARM_SELECT_FLAG]
      ,[EVENT_CLOSE_STATUS_FLAG]
      ,[WORK_ORDER_APPROVED_INDICATOR]
      ,[PRODCTN_COST]
      ,[EDIT_FLAG]
      ,[UPDATED_BY]
      ,[DOWNTIME_AUDIT_ID]
      ,[DOWNTIME_AUDIT_TYPE]
      ,[CREATED_BY]
      ,[WORK_ORDER_ORIG]
      ,[AUTO_SPLIT_ROOT]
      ,[DW_LOAD_TS]
      ,[UTC_CREATED_DATE]
FROM [dbo].[CRUSHER_STATUS_STG]
 
END


