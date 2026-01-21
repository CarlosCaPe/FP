



/******************************************************************  
* PROCEDURE	: dbo.[UtcShiftDate_Get]
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 08 Aug 2023
* SAMPLE	: 
	1. EXEC dbo.UTCShiftDate_Get 'CURR', 'CVE'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {08 Aug 2023}		{lwasini}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[UTCShiftDate_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	IF @SITE = 'BAG'
	BEGIN
		
		SELECT 
			DATEADD(HOUR,7,SHIFTSTARTDATETIME) UtcShiftStartDateTime,
			DATEADD(HOUR,7,SHIFTENDDATETIME) UtcShiftEndDateTime
		FROM [bag].[CONOPS_BAG_SHIFT_INFO_V]
		WHERE shiftflag = @SHIFT;
		
		
	END

	ELSE IF @SITE = 'CVE'
	BEGIN
		
		SELECT 
			DATEADD(HOUR,5,SHIFTSTARTDATETIME) UtcShiftStartDateTime,
			DATEADD(HOUR,5,SHIFTENDDATETIME) UtcShiftEndDateTime
		FROM [cer].[CONOPS_CER_SHIFT_INFO_V]
		WHERE shiftflag = @SHIFT;

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		
		SELECT 
			DATEADD(HOUR,7,SHIFTSTARTDATETIME) UtcShiftStartDateTime,
			DATEADD(HOUR,7,SHIFTENDDATETIME) UtcShiftEndDateTime
		FROM [chi].[CONOPS_CHI_SHIFT_INFO_V]
		WHERE shiftflag = @SHIFT;

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT 
			DATEADD(HOUR,7,SHIFTSTARTDATETIME) UtcShiftStartDateTime,
			DATEADD(HOUR,7,SHIFTENDDATETIME) UtcShiftEndDateTime
		FROM [cli].[CONOPS_CLI_SHIFT_INFO_V]
		WHERE shiftflag = @SHIFT;

		
	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT 
			DATEADD(HOUR,7,SHIFTSTARTDATETIME) UtcShiftStartDateTime,
			DATEADD(HOUR,7,SHIFTENDDATETIME) UtcShiftEndDateTime
		FROM [mor].[CONOPS_MOR_SHIFT_INFO_V]
		WHERE shiftflag = @SHIFT;

		
	END

	ELSE IF @SITE = 'SAM'
	BEGIN

		SELECT 
			DATEADD(HOUR,7,SHIFTSTARTDATETIME) UtcShiftStartDateTime,
			DATEADD(HOUR,7,SHIFTENDDATETIME) UtcShiftEndDateTime
		FROM [saf].[CONOPS_SAF_SHIFT_INFO_V]
		WHERE shiftflag = @SHIFT;

		

	END

	ELSE IF @SITE = 'SIE'
	BEGIN

		SELECT 
			DATEADD(HOUR,7,SHIFTSTARTDATETIME) UtcShiftStartDateTime,
			DATEADD(HOUR,7,SHIFTENDDATETIME) UtcShiftEndDateTime
		FROM [sie].[CONOPS_SIE_SHIFT_INFO_V];


	END

END


