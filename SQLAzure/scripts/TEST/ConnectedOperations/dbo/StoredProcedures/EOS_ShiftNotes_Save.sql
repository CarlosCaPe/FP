










/******************************************************************  
* PROCEDURE	: dbo.EOS_ShiftNotes_Save
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 21 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_ShiftNotes_Save '5E3F2E9F-48B0-4413-863B-4569A720C1AB', 'CVE', 'NIGHT SHIFT', '2023-06-21 00:00:00.000', 'OTHER', 'notes 20', '0060092257'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Jun 2023}		{sxavier}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_ShiftNotes_Save] 
(	
	@ShiftNotesId UNIQUEIDENTIFIER,
	@SiteCode CHAR(3),
	@Shift VARCHAR(16),
	@ShiftDate DATETIME,
	@Category VARCHAR(64),
	@ShiftNotes VARCHAR(MAX),
	@EmployeeId CHAR(10)
)
AS                        
BEGIN    
	SET NOCOUNT ON
	SET XACT_ABORT ON

	BEGIN TRANSACTION

	IF EXISTS (SELECT ShiftNotesId FROM dbo.CONOPS_EOS_SHIFTNOTES_V WHERE ShiftNotesId = @ShiftNotesId)
	BEGIN
		UPDATE 
			dbo.ShiftNotes
		SET
			ShiftNotes = @ShiftNotes,
			ModifiedBy = @EmployeeId,
			UtcModifiedDate = GETUTCDATE()
		WHERE
			ShiftNotesId = @ShiftNotesId
	END
	ELSE
	BEGIN
		INSERT INTO dbo.ShiftNotes
		(
			ShiftNotesId,
			SiteCode,
			[Shift],
			ShiftDate,
			Category,
			ShiftNotes,
			CreatedBy,
			UtcCreatedDate,
			ModifiedBy,
			UtcModifiedDate
		)
		VALUES
		(
			NEWID(),
			@SiteCode,
			@Shift,
			@ShiftDate,
			@Category,
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


