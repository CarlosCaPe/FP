
/******************************************************************  
* PROCEDURE	: dbo.CONOPS_JOB_STATUS_GET
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 18 Sep 2024
* SAMPLE	: 
	1. EXEC dbo.CONOPS_JOB_STATUS_GET 'BAG', 'EN'
	2. EXEC dbo.CONOPS_JOB_STATUS_GET 'BAG', 'ES'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {18 Sep 2024}		{ggosal1}		{Initial Created} 
* {24 Dec 2024}		{ggosal1}		{Add Espanol Lang} 
* {12 Nov 2025}		{ggosal1}		{Add Asset Eff Bag} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CONOPS_JOB_STATUS_GET] 
(	
	@SITE VARCHAR(4),
	@LANG CHAR(2)
)
AS                        
BEGIN          
	
	IF @SITE = 'BAG'
	BEGIN
	
	DECLARE @DupStatusMsg NVARCHAR(MAX);

	WITH Dup AS(
	SELECT
		eqmt,
		startdatetime,
		eqmt + ' (' + CAST(startdatetime AS varchar) + ')' AS DupStatus
	FROM bag2.ASSET_EFFICIENCY_STG_TEMP WITH(NOLOCK)
	GROUP BY eqmt, startdatetime
	HAVING COUNT(*) > 1
	)

	SELECT @DupStatusMsg = STRING_AGG(ISNULL(DupStatus, ''), ', ')
	FROM Dup

		IF @LANG = 'EN'
		BEGIN

			--SELECT
			--	SITE_CODE,
			--	JOB_NAME,
			--	TABLE_NAME,
			--	JOB_TYPE,
			--	MAX_DATA_LOCAL_TS,
			--	MAX_DATA_LOAD_LOCAL_TS,
			--	LATE_MINS,
			--	JOB_SCHEDULE_MINS,
			--	JOB_ALERT_MINS,
			--	SOURCE_TYPE,
			--	SOURCE_URL,
			--	CONCAT('Current ', JOB_TYPE, ' is not available. Please update it on the ', SOURCE_TYPE, ' (', SOURCE_URL, ')') AS Message
			--FROM BAG.CONOPS_BAG_JOB_STATUS_V
			--WHERE JOB_TYPE LIKE '%Target'
			--AND MAX_DATA_LOCAL_TS IS NULL

			--UNION

			--SELECT
			--	SITE_CODE,
			--	JOB_NAME,
			--	TABLE_NAME,
			--	JOB_TYPE,
			--	MAX_DATA_LOCAL_TS,
			--	MAX_DATA_LOAD_LOCAL_TS,
			--	LATE_MINS,
			--	JOB_SCHEDULE_MINS,
			--	JOB_ALERT_MINS,
			--	SOURCE_TYPE,
			--	SOURCE_URL,
			--	CONCAT('Current ', JOB_TYPE, ' is not updated (Latest data = ', MAX_DATA_LOCAL_TS, '). Please update it on the ', SOURCE_TYPE, ' (', SOURCE_URL, ')') AS Message
			--FROM BAG.CONOPS_BAG_JOB_STATUS_V
			--WHERE JOB_TYPE LIKE '%Target'
			--AND MAX_DATA_LOCAL_TS < MAX_DATA_LOAD_LOCAL_TS

			--UNION

			SELECT
				SITE_CODE,
				JOB_NAME,
				TABLE_NAME,
				JOB_TYPE,
				MAX_DATA_LOCAL_TS,
				MAX_DATA_LOAD_LOCAL_TS,
				LATE_MINS,
				JOB_SCHEDULE_MINS,
				JOB_ALERT_MINS,
				SOURCE_TYPE,
				SOURCE_URL,
				CONCAT('The ', TABLE_NAME, ' table replication has been delayed for ', FORMAT(LATE_MINS,'N0'), 
					' minutes (Last updated = ', MAX_DATA_LOAD_LOCAL_TS, '). Please contact the support team for assistance.') AS Message
			FROM BAG.CONOPS_BAG_JOB_STATUS_V
			WHERE LATE_MINS > JOB_ALERT_MINS
			AND job_name <> 'job_conops_asset_efficiency_bag'

			UNION

			--Asset Efficiency
			SELECT
				SITE_CODE,
				JOB_NAME,
				TABLE_NAME,
				JOB_TYPE,
				MAX_DATA_LOCAL_TS,
				MAX_DATA_LOAD_LOCAL_TS,
				LATE_MINS,
				JOB_SCHEDULE_MINS,
				JOB_ALERT_MINS,
				SOURCE_TYPE,
				SOURCE_URL,
				CONCAT('The ', TABLE_NAME, ' table replication has been delayed for ', FORMAT(LATE_MINS,'N0'), 
					' minutes (Last updated = ', MAX_DATA_LOAD_LOCAL_TS, '). Please check status records for ', @DupStatusMsg, '.') AS Message
			FROM BAG.CONOPS_BAG_JOB_STATUS_V
			WHERE job_name = 'job_conops_asset_efficiency_bag'
			--AND LATE_MINS > JOB_ALERT_MINS --for testing


		END

		ELSE IF @LANG = 'ES'
		BEGIN

			--SELECT
			--	SITE_CODE,
			--	JOB_NAME,
			--	TABLE_NAME,
			--	JOB_TYPE,
			--	MAX_DATA_LOCAL_TS,
			--	MAX_DATA_LOAD_LOCAL_TS,
			--	LATE_MINS,
			--	JOB_SCHEDULE_MINS,
			--	JOB_ALERT_MINS,
			--	SOURCE_TYPE,
			--	SOURCE_URL,
			--	CONCAT('El ', JOB_TYPE, ' actual no estÃ¡ disponible. Por favor, actualÃ­zalo en el ', SOURCE_TYPE, ' (', SOURCE_URL, ')') AS Message
			--FROM BAG.CONOPS_BAG_JOB_STATUS_V
			--WHERE JOB_TYPE LIKE '%Target'
			--AND MAX_DATA_LOCAL_TS IS NULL

			--UNION
