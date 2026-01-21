











/******************************************************************  
* PROCEDURE	: dbo.EOS_ShiftNotesLineUpOperators_Save
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 26 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_ShiftNotesLineUpOperators_Save 'Support', 'MOR', 'NIGHT SHIFT', '2023-06-25 00:00:00.000', 1, 1, 'notes aab', '0060092257'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Jun 2023}		{sxavier}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_ShiftNotesLineUpOperators_Save] 
(	
	@Operator VARCHAR(16),
	@SiteCode CHAR(3),
	@Shift VARCHAR(16),
	@ShiftDate DATETIME,
	@Actual INT,
	@Plan INT,
	@ShiftNotes VARCHAR(MAX),
	@EmployeeId CHAR(10)
)
AS                        
BEGIN    
	SET NOCOUNT ON
	SET XACT_ABORT ON

	BEGIN TRANSACTION

	IF EXISTS (SELECT Operator 
				FROM dbo.CONOPS_EOS_SHIFTNOTES_LINEUPOPERATORS_V 
				WHERE Operator = @Operator AND
					SiteCode = @SiteCode AND
					[Shift] = @Shift AND
					ShiftDate= @ShiftDate)
	BEGIN
		UPDATE 
			dbo.ShiftNotesLineUpOperators
		SET
			Actual = @Actual,
			[Plan] = @Plan,
			ShiftNotes = @ShiftNotes,
			ModifiedBy = @EmployeeId,
			UtcModifiedDate = GETUTCDATE()
		WHERE
			Operator = @Operator AND
			SiteCode = @SiteCode AND
			[Shift] = @Shift AND
			ShiftDate= @ShiftDate
	END
	ELSE
	BEGIN
		INSERT INTO dbo.ShiftNotesLineUpOperators
		(
			Operator,
			SiteCode,
			[Shift],
			ShiftDate,
			Actual,
			[Plan],
			ShiftNotes,
			CreatedBy,
			UtcCreatedDate,
			ModifiedBy,
			UtcModifiedDate
		)
		VALUES
		(
			@Operator,
			@SiteCode,
			@Shift,
			@ShiftDate,
			@Actual,
			@Plan,
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



