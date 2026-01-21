




/******************************************************************  
* PROCEDURE	: dbo.OperatorID_Lookup
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 03 Nov 2023
* SAMPLE	: 
	1. EXEC dbo.OperatorID_Lookup 'PREV', 'CVE', '00068805'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {03 Nov 2023}		{ggosal1}		{Initial Created}  
*******************************************************************/ 
CREATE PROCEDURE [dbo].[OperatorID_Lookup] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@OPERID VARCHAR(50)
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

		SELECT DISTINCT
			si.ShiftStartDate,
			si.ShiftName,
			RIGHT('0000000000' + op.OPERATOR_ID, 10) AS EmployeeID
		FROM dbo.operator_personnel_map op WITH(NOLOCK)
		RIGHT JOIN BAG.CONOPS_BAG_SHIFT_INFO_V si WITH(NOLOCK)
			ON op.SHIFTINDEX = si.SHIFTINDEX 
		WHERE op.SITE_CODE = @SITE
			AND si.SHIFTFLAG = @SHIFT
			AND (
				RIGHT('0000000000' + op.OPERATOR_ID, 10) = @OPERID
				OR
				op.OPERATOR_ID = @OPERID
			)

	END

	ELSE IF @SITE = 'CER'
	BEGIN

		SELECT DISTINCT
			si.ShiftStartDate,
			si.ShiftName,
			RIGHT('0000000000' + op.PERSONNEL_ID, 10) AS EmployeeID
		FROM dbo.operator_personnel_map op WITH(NOLOCK)
		RIGHT JOIN CER.CONOPS_CER_SHIFT_INFO_V si WITH(NOLOCK)
			ON op.SHIFTINDEX = si.SHIFTINDEX 
		WHERE op.SITE_CODE = @SITE
			AND si.SHIFTFLAG = @SHIFT
			AND (
				RIGHT('0000000000' + op.OPERATOR_ID, 10) = @OPERID
				OR
				op.OPERATOR_ID = @OPERID
			)

	END

	ELSE IF @SITE = 'CHI'
	BEGIN

		SELECT DISTINCT
			si.ShiftStartDate,
			si.ShiftName,
			RIGHT('0000000000' + op.OPERATOR_ID, 10) AS EmployeeID
		FROM dbo.operator_personnel_map op WITH(NOLOCK)
		RIGHT JOIN CHI.CONOPS_CHI_SHIFT_INFO_V si WITH(NOLOCK)
			ON op.SHIFTINDEX = si.SHIFTINDEX 
		WHERE op.SITE_CODE = @SITE
			AND si.SHIFTFLAG = @SHIFT
			AND (
				RIGHT('0000000000' + op.OPERATOR_ID, 10) = @OPERID
				OR
				op.OPERATOR_ID = @OPERID
			)

	END

	ELSE IF @SITE = 'CLI'
	BEGIN

		SELECT DISTINCT
			si.ShiftStartDate,
			si.ShiftName,
			RIGHT('0000000000' + op.OPERATOR_ID, 10) AS EmployeeID
		FROM dbo.operator_personnel_map op WITH(NOLOCK)
		RIGHT JOIN CLI.CONOPS_CLI_SHIFT_INFO_V si WITH(NOLOCK)
			ON op.SHIFTINDEX = si.SHIFTINDEX 
		WHERE op.SITE_CODE = @SITE
			AND si.SHIFTFLAG = @SHIFT
			AND (
				RIGHT('0000000000' + op.OPERATOR_ID, 10) = @OPERID
				OR
				op.OPERATOR_ID = @OPERID
			)

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT DISTINCT
			si.ShiftStartDate,
			si.ShiftName,
			RIGHT('0000000000' + op.OPERATOR_ID, 10) AS EmployeeID
		FROM dbo.operator_personnel_map op WITH(NOLOCK)
		RIGHT JOIN MOR.CONOPS_MOR_SHIFT_INFO_V si WITH(NOLOCK)
			ON op.SHIFTINDEX = si.SHIFTINDEX 
		WHERE op.SITE_CODE = @SITE
			AND si.SHIFTFLAG = @SHIFT
			AND (
				RIGHT('0000000000' + op.OPERATOR_ID, 10) = @OPERID
				OR
				op.OPERATOR_ID = @OPERID
			)

	END

	ELSE IF @SITE = 'SAM'
	BEGIN

		SELECT DISTINCT
			si.ShiftStartDate,
			si.ShiftName,
			RIGHT('0000000000' + op.OPERATOR_ID, 10) AS EmployeeID
		FROM dbo.operator_personnel_map op WITH(NOLOCK)
		RIGHT JOIN SAF.CONOPS_SAF_SHIFT_INFO_V si WITH(NOLOCK)
			ON op.SHIFTINDEX = si.SHIFTINDEX 
		WHERE op.SITE_CODE = @SITE
			AND si.SHIFTFLAG = @SHIFT
			AND (
				RIGHT('0000000000' + op.OPERATOR_ID, 10) = @OPERID
				OR
				op.OPERATOR_ID = @OPERID
			)

	END

	ELSE IF @SITE = 'SIE'
	BEGIN

		SELECT DISTINCT
			si.ShiftStartDate,
			si.ShiftName,
			RIGHT('0000000000' + op.OPERATOR_ID, 10) AS EmployeeID
		FROM dbo.operator_personnel_map op WITH(NOLOCK)
		RIGHT JOIN SIE.CONOPS_SIE_SHIFT_INFO_V si WITH(NOLOCK)
			ON op.SHIFTINDEX = si.SHIFTINDEX 
		WHERE op.SITE_CODE = @SITE
			AND si.SHIFTFLAG =