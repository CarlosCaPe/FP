



/******************************************************************  
* PROCEDURE	: dbo.EOS_ShiftNotesLineUpEquipments_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 26 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_ShiftNotesLineUpEquipments_Get 'CURR', 'BAG', NULL, NULL,0
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Jun 2023}		{sxavier}		{Initial Created} 
* {25 Sep 2023}		{sxavier}		{Add parameter ShiftName and ShiftDate} 
* {07 Dec 2023}		{lwasini}		{Add Daily Summary}
* {30 Jan 2024}		{lwasini}		{Add TYR & ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_ShiftNotesLineUpEquipments_Get] 
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
			A.Equipment,
			CASE WHEN B.EquipmentAvailableShiftStart IS NOT NULL THEN B.EquipmentAvailableShiftStart ELSE SUM(A.EquipmentAvailable) END AS EquipmentAvailableShiftStart,
			B.ShiftNotes
		FROM 
			[bag].[CONOPS_BAG_EOS_LINEUP_EQUIPMENT_V] A
			LEFT JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_LINEUPEQUIPMENTS_V] B
				ON A.ShiftId = B.ShiftId AND B.SiteCode = 'BAG' AND A.Equipment = B.Equipment
		WHERE 
			(A.ShiftFlag = @Shift AND @Shift IS NOT NULL) OR (A.ShiftId = @ShiftId AND @Shift IS NULL)
		GROUP BY A.Equipment,B.EquipmentAvailableShiftStart,B.ShiftNotes
		ORDER BY A.Equipment;
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT
			A.Equipment,
			CASE WHEN B.EquipmentAvailableShiftStart IS NOT NULL THEN B.EquipmentAvailableShiftStart ELSE SUM(A.EquipmentAvailable) END AS EquipmentAvailableShiftStart,
			B.ShiftNotes
		FROM 
			[bag].[CONOPS_BAG_DAILY_EOS_LINEUP_EQUIPMENT_V] A
			LEFT JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_LINEUPEQUIPMENTS_V] B
				ON A.ShiftId = B.ShiftId AND B.SiteCode = 'BAG' AND A.Equipment = B.Equipment
		WHERE 
			(A.ShiftFlag = @Shift AND @Shift IS NOT NULL) OR (A.ShiftId = @ShiftId AND @Shift IS NULL)
		GROUP BY A.Equipment,B.EquipmentAvailableShiftStart,B.ShiftNotes
		ORDER BY A.Equipment;
		END
		
	END

	

	ELSE IF @SITE = 'CVE' 
	BEGIN
		
		IF @DAILY = 0
		BEGIN
		SELECT
			A.Equipment,
			CASE WHEN B.EquipmentAvailableShiftStart IS NOT NULL THEN B.EquipmentAvailableShiftStart ELSE SUM(A.EquipmentAvailable) END AS EquipmentAvailableShiftStart,
			B.ShiftNotes
		FROM 
			[cer].[CONOPS_CER_EOS_LINEUP_EQUIPMENT_V] A
			LEFT JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_LINEUPEQUIPMENTS_V] B
				ON A.ShiftId = B.ShiftId AND B.SiteCode = 'CVE' AND A.Equipment = B.Equipment
		WHERE 
			(A.ShiftFlag = @Shift AND @Shift IS NOT NULL) OR (A.ShiftId = @ShiftId AND @Shift IS NULL)
		GROUP BY A.Equipment,B.EquipmentAvailableShiftStart,B.ShiftNotes
		ORDER BY A.Equipment;
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT
			A.Equipment,
			CASE WHEN B.EquipmentAvailableShiftStart IS NOT NULL THEN B.EquipmentAvailableShiftStart ELSE SUM(A.EquipmentAvailable) END AS EquipmentAvailableShiftStart,
			B.ShiftNotes
		FROM 
			[cer].[CONOPS_CER_DAILY_EOS_LINEUP_EQUIPMENT_V] A
			LEFT JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_LINEUPEQUIPMENTS_V] B
				ON A.ShiftId = B.ShiftId AND B.SiteCode = 'CVE' AND A.Equipment = B.Equipment
		WHERE 
			(A.ShiftFlag = @Shift AND @Shift IS NOT NULL) OR (A.ShiftId = @ShiftId AND @Shift IS NULL)
		GROUP BY A.Equipment,B.EquipmentAvailableShiftStart,B.ShiftNotes
		ORDER BY A.Equipment;
		END

	END

	

	ELSE IF @SITE = 'CHN' 
	BEGIN
		
		IF @DAILY = 0
		BEGIN
		SELECT
			A.Equipment,
			CASE WHEN B.EquipmentAvailableShiftStart IS NOT NULL THEN B.EquipmentA