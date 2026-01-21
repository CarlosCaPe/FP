

/******************************************************************  
* PROCEDURE	: dbo.Equipment_Alarm_OperatorBreak_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 31 Mar 2023
* SAMPLE	: 
	1. EXEC dbo.Equipment_Alarm_OperatorBreak_Get 'PREV', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {31 Mar 2023}		{jrodulfa}		{Initial Created}}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Equipment_Alarm_OperatorBreak_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	DECLARE @SCHEMA VARCHAR(4);

	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;

	SET @SCHEMA = CASE @SITE 
					   WHEN 'CMX' THEN 'CLI'
					   ELSE @SITE
				  END;

	EXEC('
		SELECT shiftflag, [AlertType], [AlertName]
			  ,EQUIPMENTNUMBER, END_TIME_TS, STATUS_DURATION
			  ,OPERATORID, OperatorImageURL, OperatorName
		FROM [' + @SCHEMA + '].[CONOPS_' + @SCHEMA + '_EQMT_ALARM_TRUCK_SHOVEL_OPERATOR_BREAK_V] WITH (NOLOCK)
		WHERE shiftflag = ''' + @SHIFT + '''
			  AND siteflag = ''' + @SITE + '''
			  AND num = 1
		UNION ALL
		SELECT shiftflag, [AlertType], [AlertName]
			  ,EQUIPMENTNUMBER, END_TIME_TS, STATUS_DURATION
			  ,OPERATORID, OperatorImageURL, OperatorName
		FROM [' + @SCHEMA + '].[CONOPS_' + @SCHEMA + '_EQMT_ALARM_DRILL_OPERATOR_BREAK_V] WITH (NOLOCK)
		WHERE shiftflag = ''' + @SHIFT + '''
			  AND siteflag = ''' + @SITE + '''
			  AND num = 1
		ORDER BY END_TIME_TS
	');

SET NOCOUNT OFF
END

