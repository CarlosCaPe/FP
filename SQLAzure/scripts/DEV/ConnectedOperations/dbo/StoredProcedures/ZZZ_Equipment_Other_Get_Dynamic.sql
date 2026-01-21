
/******************************************************************  
* PROCEDURE	: dbo.Equipment_Truck_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: mbote, 28 Mar 2023
* SAMPLE	: 
	1. EXEC dbo.Equipment_Other_Get 'PREV', 'BAG', NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {28 Mar 2023}		{mbote}		{Initial Created}}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Equipment_Other_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX)
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
		SELECT 
			[shiftflag],
			[siteflag],
			[shiftid],
			[SHIFTINDEX],
			[SupportEquipmentId],
			[SupportEquipment],
			[StatusCode],
			[StatusName],
			[ReasonId],
			[ReasonDesc],
			[StatusStart],
			[Location],
			[Region],
			[Operator],
			[OperatorImageURL],
			[Duration]
		FROM [' + @SCHEMA + '].[CONOPS_' + @SCHEMA + '_EQMT_OTHER_V]
		WHERE shiftflag = ''' + @SHIFT + '''
		AND siteflag = ''' + @SITE + '''
		AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(''' + @STATUS + '''), '','')) OR ISNULL(''' + @STATUS + ''', '''') = '''')
	');

SET NOCOUNT OFF
END