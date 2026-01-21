
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
			--	CONCAT('El ', JOB_TYPE, ' actual no está disponible. Por favor, actualízalo en el ', SOURCE_TYPE, ' (', SOURCE_URL, ')') AS Message
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
			--	CONCAT('El ', JOB_TYPE, ' actual no está actualizado (Últimos datos = ', MAX_DATA_LOCAL_TS, '). Por favor, actualízalo en el ', SOURCE_TYPE, ' (', SOURCE_URL, ')') AS Message
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
				CONCAT('La replicación de la tabla ', TABLE_NAME, ' ha tenido un retraso de ', FORMAT(LATE_MINS,'N0'), 
					' minutos (Última actualización = ', MAX_DATA_LOAD_LOCAL_TS, '). Por favor, contacta al equipo de soporte para obtener ayuda.') AS Message
			FROM BAG.CONOPS_BAG_JOB_STATUS_V
			W