

/******************************************************************  
* PROCEDURE	: dbo.Equipment_Alarm_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 12 May 2023
* SAMPLE	: 
	1. EXEC dbo.Equipment_Alarm_Get 'PREV', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {12 May 2023}		{jrodulfa}		{Initial Created}}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Equipment_Alarm_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;

	IF @SITE = 'BAG'
	BEGIN
		SELECT [SHIFTFLAG]
			  ,[ALERT_TYPE]
			  ,[ALERT_NAME]
			  ,[ALERT_DESCRIPTION]
			  ,[EQMTID]
			  ,CASE WHEN [OPERATOR_ID] IS NULL OR [OPERATOR_ID] = -1 THEN NULL
					ELSE concat('https://images.services.fmi.com/publishedimages/',
						   RIGHT('0000000000' + [OPERATOR_ID], 10),'.jpg') END as OperatorImageURL
			  ,CONVERT(VARCHAR(8),[ALERT_DATE],108) AS [ALERT_DATE]
			  ,[DURATION]
		FROM [bag].[CONOPS_BAG_ALERT_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE;
	END

	ELSE IF @SITE = 'CER'
	BEGIN
		SELECT [SHIFTFLAG]
			  ,[ALERT_TYPE]
			  ,[ALERT_NAME]
			  ,[ALERT_DESCRIPTION]
			  ,[EQMTID]
			  ,CASE WHEN [OPERATOR_ID] IS NULL OR [OPERATOR_ID] = -1 THEN NULL
					ELSE concat('https://images.services.fmi.com/publishedimages/',
						   RIGHT('0000000000' + [OPERATOR_ID], 10),'.jpg') END as OperatorImageURL
			  ,CONVERT(VARCHAR(8),[ALERT_DATE],108) AS [ALERT_DATE]
			  ,[DURATION]
		FROM [cer].[CONOPS_CER_ALERT_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE;
	END

	ELSE IF @SITE = 'CHI'
	BEGIN
		SELECT [SHIFTFLAG]
			  ,[ALERT_TYPE]
			  ,[ALERT_NAME]
			  ,[ALERT_DESCRIPTION]
			  ,[EQMTID]
			  ,CASE WHEN [OPERATOR_ID] IS NULL OR [OPERATOR_ID] = -1 THEN NULL
					ELSE concat('https://images.services.fmi.com/publishedimages/',
						   RIGHT('0000000000' + [OPERATOR_ID], 10),'.jpg') END as OperatorImageURL
			  ,CONVERT(VARCHAR(8),[ALERT_DATE],108) AS [ALERT_DATE]
			  ,[DURATION]
		FROM [chi].[CONOPS_CHI_ALERT_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE;
	END

	ELSE IF @SITE = 'CMX'
	BEGIN
		SELECT [SHIFTFLAG]
			  ,[ALERT_TYPE]
			  ,[ALERT_NAME]
			  ,[ALERT_DESCRIPTION]
			  ,[EQMTID]
			  ,CASE WHEN [OPERATOR_ID] IS NULL OR [OPERATOR_ID] = -1 THEN NULL
					ELSE concat('https://images.services.fmi.com/publishedimages/',
						   RIGHT('0000000000' + [OPERATOR_ID], 10),'.jpg') END as OperatorImageURL
			  ,CONVERT(VARCHAR(8),[ALERT_DATE],108) AS [ALERT_DATE]
			  ,[DURATION]
		FROM [cli].[CONOPS_CLI_ALERT_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE;
	END

	ELSE IF @SITE = 'MOR'
	BEGIN
		SELECT [SHIFTFLAG]
			  ,[ALERT_TYPE]
			  ,[ALERT_NAME]
			  ,[ALERT_DESCRIPTION]
			  ,[EQMTID]
			  ,CASE WHEN [OPERATOR_ID] IS NULL OR [OPERATOR_ID] = -1 THEN NULL
					ELSE concat('https://images.services.fmi.com/publishedimages/',
						   RIGHT('0000000000' + [OPERATOR_ID], 10),'.jpg') END as OperatorImageURL
			  ,CONVERT(VARCHAR(8),[ALERT_DATE],108) AS [ALERT_DATE]
			  ,[DURATION]
		FROM [mor].[CONOPS_MOR_ALERT_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE;
	END

	ELSE IF @SITE = 'SAF'
	BEGIN
		SELECT [SHIFTFLAG]
			  ,[ALERT_TYPE]
			  ,[ALERT_NAME]
			  ,[ALERT_DESCRIPTION]
			  ,[EQMTID]
			  ,CASE WHEN [OPERATOR_ID] IS NULL OR [OPERATOR_ID] = -1 THEN NULL
					ELSE concat('https://images.services.fmi.com/publishedimages/',
						   RIGHT('0000000000' + [OPERATOR_ID], 10),'.jpg') END as OperatorImageURL
			  ,CONVERT(VARCHAR(8),[ALERT_DATE],108) AS [ALERT_DATE]
			  ,[DURATION]
		FROM [saf].[CONOPS_SAF_ALERT_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			  