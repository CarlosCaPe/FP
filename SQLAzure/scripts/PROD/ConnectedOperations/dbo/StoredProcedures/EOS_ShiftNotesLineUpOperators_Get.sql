

/******************************************************************  
* PROCEDURE	: dbo.EOS_ShiftNotesLineUpOperators_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 26 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_ShiftNotesLineUpOperators_Get 'PREV', 'MOR', NULL, NULL,0
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Jun 2023}		{sxavier}		{Initial Created} 
* {25 Sep 2023}		{sxavier}		{Add parameter ShiftName and ShiftDate} 
* {07 Dec 2023}		{lwasini}		{Add Daily Summary}
* {30 Jan 2024}		{lwasini}		{Add TYR & ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_ShiftNotesLineUpOperators_Get] 
(	
	@SHIFT CHAR(4),
	@SITE CHAR(3),
	@SHIFTNAME VARCHAR(16),
	@SHIFTDATE DATETIME,
	@DAILY INT
)
AS                        
BEGIN    

BEGIN TRY

	DECLARE @ShiftId VARCHAR(16)
	SET @ShiftId = CASE WHEN @SHIFTNAME = 'NIGHT SHIFT' THEN CONCAT(RIGHT(REPLACE(CAST(@SHIFTDATE AS DATE), '-', ''), 6), '002')
		ELSE CONCAT(RIGHT(REPLACE(CAST(@SHIFTDATE AS DATE), '-', ''), 6), '001') END
	
	IF @SITE = 'BAG' 
	BEGIN
		
		IF @DAILY = 0
		BEGIN
		SELECT
			B.Operator,
			B.Actual,
			B.[Plan],
			B.ShiftNotes
		FROM 
			[bag].[CONOPS_BAG_SHIFT_INFO_V] A
			INNER JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_LINEUPOPERATORS_V] B ON A.ShiftId = B.ShiftId AND B.SiteCode = 'BAG'
		WHERE
			(A.ShiftFlag = @Shift AND @Shift IS NOT NULL) OR (A.ShiftId = @ShiftId AND @Shift IS NULL)
		ORDER BY B.Operator
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT
			B.Operator,
			B.Actual,
			B.[Plan],
			B.ShiftNotes
		FROM 
			[bag].[CONOPS_BAG_EOS_SHIFT_INFO_V] A
			INNER JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_LINEUPOPERATORS_V] B ON A.ShiftId = B.ShiftId AND B.SiteCode = 'BAG'
		WHERE
			(A.ShiftFlag = @Shift AND @Shift IS NOT NULL) OR (A.ShiftId = @ShiftId AND @Shift IS NULL)
		ORDER BY B.Operator
		END

	END

	

	ELSE IF @SITE = 'CVE' 
	BEGIN
		
		IF @DAILY = 0 
		BEGIN
		SELECT
			B.Operator,
			B.Actual,
			B.[Plan],
			B.ShiftNotes
		FROM 
			[cer].[CONOPS_CER_SHIFT_INFO_V] A 
			INNER JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_LINEUPOPERATORS_V] B ON A.ShiftId = B.ShiftId AND B.SiteCode = 'CVE'
		WHERE
			(A.ShiftFlag = @Shift AND @Shift IS NOT NULL) OR (A.ShiftId = @ShiftId AND @Shift IS NULL)
		ORDER BY B.Operator
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT
			B.Operator,
			B.Actual,
			B.[Plan],
			B.ShiftNotes
		FROM 
			[cer].[CONOPS_CER_EOS_SHIFT_INFO_V] A 
			INNER JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_LINEUPOPERATORS_V] B ON A.ShiftId = B.ShiftId AND B.SiteCode = 'CVE'
		WHERE
			(A.ShiftFlag = @Shift AND @Shift IS NOT NULL) OR (A.ShiftId = @ShiftId AND @Shift IS NULL)
		ORDER BY B.Operator
		END

	END

	

	ELSE IF @SITE = 'CHN' 
	BEGIN
		
		IF @DAILY = 0
		BEGIN
		SELECT
			B.Operator,
			B.Actual,
			B.[Plan],
			B.ShiftNotes
		FROM 
			[chi].[CONOPS_CHI_SHIFT_INFO_V] A
			INNER JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_LINEUPOPERATORS_V] B ON A.ShiftId = B.ShiftId AND B.SiteCode = 'CHN'
		WHERE
			(A.ShiftFlag = @Shift AND @Shift IS NOT NULL) OR (A.ShiftId = @ShiftId AND @Shift IS NULL)
		ORDER BY B.Operator
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT
			B.Operator,
			B.Actual,
			B.[Plan],
			B.ShiftNotes
		FROM 
			[chi].[CONOPS_CHI_EOS_SHIFT_INFO_V] A
			INNER JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_LINEUPOPERATORS_V] B ON A.ShiftId = B.ShiftId AND B.SiteCode = 'CHN'
		WHERE
			(A.ShiftFlag = @Shift AND @Shift IS NOT NULL) OR (A.ShiftId = @ShiftId AND @Shift IS NULL)
		ORDER BY B.Operator
		END

	END



	ELSE IF @SITE = 'CMX' 
	BEGIN
		
		IF @DAILY = 0
		BEGIN
		SELECT
			B.Operator,
			B.Actual,
			B.[Plan],
			B.ShiftNotes
		FROM 
			[cli].[CONOPS_CLI_SHIFT_INFO_V] A
			INNER JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_LINEUPOPERATORS_V] B ON A.ShiftId = B.ShiftId AND B.SiteCode = 'CMX'
		WHERE
			(A.ShiftFlag = @Shift A