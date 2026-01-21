















/******************************************************************  
* PROCEDURE	: dbo.EOS_ShiftNotesDrillOperatorStartSummaries_Save
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 23 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_ShiftNotesDrillOperatorStartSummaries_Save '10R', '2023-06-25 07:42:23.000', 10, 'MOR', 'DAY SHIFT', '2023-06-25 00:00:00.000', 'abcd', '0060092257'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {23 Jun 2023}		{sxavier}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_ShiftNotesDrillOperatorStartSummaries_Save] 
(	
	@Drill VARCHAR (16),
	@TimeFirstDrilled DATETIME,
	@HolesDrilled INT,
	@SiteCode CHAR(3),
	@Shift VARCHAR(16),
	@ShiftDate DATETIME,
	@ShiftNotes VARCHAR(MAX),
	@EmployeeId CHAR(10)
)
AS                        
BEGIN    
	SET NOCOUNT ON
	SET XACT_ABORT ON

	BEGIN TRANSACTION

	IF EXISTS (SELECT Drill 
				FROM [dbo].[CONOPS_EOS_SHIFTNOTES_DRILLOPERATORSTARTSUMMARIES_V] (NOLOCK) 
				WHERE Drill = @Drill 
					AND SiteCode = @SiteCode 
					AND [Shift] = @Shift 
					AND ShiftDate = @ShiftDate)
	BEGIN
		UPDATE 
			dbo.ShiftNotesDrillOperatorStartSummaries
		SET
			ShiftNotes = @ShiftNotes,
			TimeFirstDrilled = @TimeFirstDrilled,
			HolesDrilled = @HolesDrilled,
			ModifiedBy = @EmployeeId,
			UtcModifiedDate = GETUTCDATE()
		WHERE
			Drill = @Drill 
			AND SiteCode = @SiteCode 
			AND [Shift] = @Shift 
			AND ShiftDate = @ShiftDate
	END
	ELSE
	BEGIN
		INSERT INTO dbo.ShiftNotesDrillOperatorStartSummaries
		(
			Drill,
			TimeFirstDrilled,
			HolesDrilled,
			SiteCode,
			[Shift],
			ShiftDate,
			ShiftNotes,
			CreatedBy,
			UtcCreatedDate,
			ModifiedBy,
			UtcModifiedDate
		)
		VALUES
		(
			@Drill,
			@TimeFirstDrilled,
			@HolesDrilled,
			@SiteCode,
			@Shift,
			@ShiftDate,
			@ShiftNotes,
			@EmployeeId,
			GETUTCDATE(),
			@EmployeeId,
			GETUTCDATE()
		)
	END

	COMMIT TRANSACTION

	SET NOCOUNT OFF

END



