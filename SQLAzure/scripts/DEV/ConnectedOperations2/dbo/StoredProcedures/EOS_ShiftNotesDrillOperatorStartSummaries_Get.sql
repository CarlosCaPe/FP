
/******************************************************************  
* PROCEDURE	: dbo.EOS_ShiftNotesDrillOperatorStartSummaries_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 22 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_ShiftNotesDrillOperatorStartSummaries_Get 'CURR', 'BAG', NULL, NULL,1
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {22 Jun 2023}		{sxavier}		{Initial Created} 
* {25 Sep 2023}		{sxavier}		{Add parameter ShiftName and ShiftDate}
* {07 Dec 2023}		{lwasini}		{Add Daily Summary} 
* {30 Jan 2024}		{lwasini}		{Add TYR & ABR}
* {02 Dec 2025}		{ggosal1}		{Add AutoDrill}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_ShiftNotesDrillOperatorStartSummaries_Get] 
(	
	@Shift CHAR(4),
	@Site CHAR(3),
	@ShiftName VARCHAR(16),
	@ShiftDate DATETIME,
	@DAILY INT
)
AS                        
BEGIN    

BEGIN TRY
	
	DECLARE @ShiftId VARCHAR(16)
	SET @ShiftId = CASE WHEN @SHIFTNAME = 'NIGHT SHIFT' THEN CONCAT(RIGHT(REPLACE(CAST(@SHIFTDATE AS DATE), '-', ''), 6), '002')
		ELSE CONCAT(RIGHT(REPLACE(CAST(@SHIFTDATE AS DATE), '-', ''), 6), '001') END

	IF @Site = 'BAG'
	BEGIN
		
		IF @DAILY = 0
		BEGIN
		SELECT
			A.Drill_ID,
			A.Average_First_Drill AS FirstTimeHoleDrilled,
			A.Holes_Drilled AS HolesDrilled,
			NULL AS NrOfAutoDrill,
			B.ShiftNotes
		FROM 
			[bag].[CONOPS_BAG_DB_DRILL_SCORE_V] A
			LEFT JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_DRILLOPERATORSTARTSUMMARIES_V] B
				ON A.ShiftId = B.ShiftId AND B.SiteCode = 'BAG' AND A.Drill_ID = B.Drill
		WHERE 
			((A.shiftflag = @Shift AND @Shift IS NOT NULL) OR (A.ShiftId = @ShiftId AND @Shift IS NULL)) AND
			A.DRILL_ID IS NOT NULL AND
			A.Average_First_Drill IS NOT NULL
		ORDER BY A.Drill_ID;
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT
			A.Drill_ID,
			A.Average_First_Drill AS FirstTimeHoleDrilled,
			A.Holes_Drilled AS HolesDrilled,
			NULL AS NrOfAutoDrill,
			B.ShiftNotes
		FROM 
			[bag].[CONOPS_BAG_DAILY_DB_DRILL_SCORE_V] A
			LEFT JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_DRILLOPERATORSTARTSUMMARIES_V] B
				ON A.ShiftId = B.ShiftId AND B.SiteCode = 'BAG' AND A.Drill_ID = B.Drill
		WHERE 
			((A.shiftflag = @Shift AND @Shift IS NOT NULL) OR (A.ShiftId = @ShiftId AND @Shift IS NULL)) AND
			A.DRILL_ID IS NOT NULL AND
			A.Average_First_Drill IS NOT NULL
		ORDER BY A.Drill_ID;
		END

	END

	ELSE IF @Site = 'CVE'
	BEGIN
		
		IF @DAILY = 0
		BEGIN
		SELECT
			A.Drill_ID,
			A.Average_First_Drill AS FirstTimeHoleDrilled,
			A.Holes_Drilled AS HolesDrilled,
			NULL AS NrOfAutoDrill,
			B.ShiftNotes
		FROM 
			[cer].[CONOPS_CER_DB_DRILL_SCORE_V] A
			LEFT JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_DRILLOPERATORSTARTSUMMARIES_V] B
				ON A.ShiftId = B.ShiftId AND B.SiteCode = 'CVE' AND A.Drill_ID = B.Drill
		WHERE 
			((A.shiftflag = @Shift AND @Shift IS NOT NULL) OR (A.ShiftId = @ShiftId AND @Shift IS NULL)) AND
			A.DRILL_ID IS NOT NULL AND
			A.Average_First_Drill IS NOT NULL
		ORDER BY A.Drill_ID;
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT
			A.Drill_ID,
			A.Average_First_Drill AS FirstTimeHoleDrilled,
			A.Holes_Drilled AS HolesDrilled,
			NULL AS NrOfAutoDrill,
			B.ShiftNotes
		FROM 
			[cer].[CONOPS_CER_DAILY_DB_DRILL_SCORE_V] A
			LEFT JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_DRILLOPERATORSTARTSUMMARIES_V] B
				ON A.ShiftId = B.ShiftId AND B.SiteCode = 'CVE' AND A.Drill_ID = B.Drill
		WHERE 
			((A.shiftflag = @Shift AND @Shift IS NOT NULL) OR (A.ShiftId = @ShiftId AND @Shift IS NULL)) AND
			A.DRILL_ID IS NOT NULL AND
			A.Average_First_Drill IS NOT NULL
		ORDER BY A.Drill_ID;
		END


	END

	ELSE IF @Site = 'CHN'
	BEGIN
		
		IF @DAILY = 0
		BEGIN
		SELECT
			A.Drill_ID,
			A.Average_First_Drill AS FirstTimeHoleDrilled,
			A.Holes_Drilled AS HolesDrilled,
			NULL AS NrOfAutoDrill,
			B.ShiftNotes
		FROM 
			[chi].[CONOPS_CHI_DB_DRILL_SCORE_V]