














/******************************************************************  
* PROCEDURE	: dbo.EOS_ShiftNotesTruckOperatorLateStarts_Save
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 23 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_ShiftNotesTruckOperatorLateStarts_Save 'EAST', 5, 'BAG', 'NIGHT SHIFT', '2023-06-22 00:00:00.000', 'notes for east with late 5', '0060092257'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {23 Jun 2023}		{sxavier}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_ShiftNotesTruckOperatorLateStarts_Save] 
(	
	@Region VARCHAR (64),
	@NumberOfLate INT,
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

	IF EXISTS (SELECT Region 
				FROM [dbo].[CONOPS_EOS_SHIFTNOTES_TRUCKOPERATORLATESTARTS_V]
				WHERE Region = @Region 
					AND SiteCode = @SiteCode 
					AND [Shift] = @Shift 
					AND ShiftDate = @ShiftDate)
	BEGIN
		UPDATE 
			dbo.ShiftNotesTruckOperatorLateStarts
		SET
			ShiftNotes = @ShiftNotes,
			NumberOfLate = @NumberOfLate,
			ModifiedBy = @EmployeeId,
			UtcModifiedDate = GETUTCDATE()
		WHERE
			Region = @Region 
			AND SiteCode = @SiteCode 
			AND [Shift] = @Shift 
			AND ShiftDate = @ShiftDate
	END
	ELSE
	BEGIN
		INSERT INTO dbo.ShiftNotesTruckOperatorLateStarts
		(
			Region,
			NumberOfLate,
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
			@Region,
			@NumberOfLate,
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



