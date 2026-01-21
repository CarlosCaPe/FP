

/******************************************************************  
* PROCEDURE	: dbo.EOS_ShiftNotesTruckOperatorLateStarts_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 22 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_ShiftNotesTruckOperatorLateStarts_Get 'CURR', 'BAG', NULL, NULL,1
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {22 Jun 2023}		{sxavier}		{Initial Created} 
* {25 Sep 2023}		{sxavier}		{Add parameter ShiftName and ShiftDate} 
* {07 Dec 2023}		{lwasini}		{Add Daily Summary}
* {30 Jan 2024}		{lwasini}		{Add TYR & ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_ShiftNotesTruckOperatorLateStarts_Get] 
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
			A.Region,
			A.LateStart,
			B.ShiftNotes
		FROM 
			(
				SELECT 
					Region,
					COUNT(b.eqmtid) AS LateStart,
					a.ShiftId
				FROM 
					[bag].[CONOPS_BAG_TRUCK_DETAIL_V] a
					LEFT JOIN [bag].[CONOPS_BAG_OPERATOR_HAS_LATE_START_V] b ON a.shiftflag = b.shiftflag AND a.TruckID = b.eqmtid AND b.unit_code = 1
				WHERE 
					(a.shiftflag = @Shift AND @Shift IS NOT NULL) OR (a.ShiftId = @ShiftId AND @Shift IS NULL)
				GROUP BY 
					a.shiftflag, region, a.shiftid
			) A
		LEFT JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_TRUCKOPERATORLATESTARTS_V] B 
			ON A.ShiftId = B.ShiftId AND B.SiteCode = 'BAG' AND A.Region = B.Region
		WHERE 
			A.LateStart <> 0
		ORDER BY A.Region
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT
			A.Region,
			A.LateStart,
			B.ShiftNotes
		FROM 
			(
				SELECT 
					Region,
					COUNT(b.eqmtid) AS LateStart,
					a.ShiftId
				FROM 
					[bag].[CONOPS_BAG_DAILY_TRUCK_DETAIL_V] a
					LEFT JOIN [bag].[CONOPS_BAG_DAILY_OPERATOR_HAS_LATE_START_V] b ON a.shiftid = b.shiftid AND a.TruckID = b.eqmtid AND b.unit_code = 1
				WHERE 
					(a.shiftflag = @Shift AND @Shift IS NOT NULL) OR (a.ShiftId = @ShiftId AND @Shift IS NULL)
				GROUP BY 
					a.shiftflag, region, a.shiftid
			) A
		LEFT JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_TRUCKOPERATORLATESTARTS_V] B 
			ON A.ShiftId = B.ShiftId AND B.SiteCode = 'BAG' AND A.Region = B.Region
		WHERE 
			A.LateStart <> 0
		ORDER BY A.Region
		END

	END

	ELSE IF @Site = 'CVE'
	BEGIN
		
		IF @DAILY = 0
		BEGIN
		SELECT
			A.Region,
			A.LateStart,
			B.ShiftNotes
		FROM 
			(
				SELECT 
					Region,
					COUNT(b.eqmtid) AS LateStart,
					a.ShiftId
				FROM 
					[cer].[CONOPS_CER_TRUCK_DETAIL_V] a
					LEFT JOIN [cer].[CONOPS_CER_OPERATOR_HAS_LATE_START_V] b ON a.shiftflag = b.shiftflag AND a.TruckID = b.eqmtid AND b.unit_code = 1
				WHERE 
					(a.shiftflag = @Shift AND @Shift IS NOT NULL) OR (a.ShiftId = @ShiftId AND @Shift IS NULL)
				GROUP BY 
					a.shiftflag, region, a.shiftid
			) A
		LEFT JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_TRUCKOPERATORLATESTARTS_V] B
			ON A.ShiftId = B.ShiftId AND B.SiteCode = 'CVE' AND A.Region = B.Region
		WHERE 
			A.LateStart <> 0
		ORDER BY A.Region
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT
			A.Region,
			A.LateStart,
			B.ShiftNotes
		FROM 
			(
				SELECT 
					Region,
					COUNT(b.eqmtid) AS LateStart,
					a.ShiftId
				FROM 
					[cer].[CONOPS_CER_DAILY_TRUCK_DETAIL_V] a
					LEFT JOIN [cer].[CONOPS_CER_DAILY_OPERATOR_HAS_LATE_START_V] b ON a.shiftid = b.shiftid AND a.TruckID = b.eqmtid AND b.unit_code = 1
				WHERE 
					(a.shiftflag = @Shift AND @Shift IS NOT NULL) OR (a.ShiftId = @ShiftId AND @Shift IS NULL)
				GROUP BY 
					a.