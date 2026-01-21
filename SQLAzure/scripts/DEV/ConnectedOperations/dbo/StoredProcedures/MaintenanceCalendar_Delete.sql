



/******************************************************************  
* PROCEDURE	: dbo.MaintenanceCalendar_Delete
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 07 Aug 2023
* SAMPLE	: 
	1. EXEC dbo.MaintenanceCalendar_Delete '4'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {07 Aug 2023}		{sxavier}		{Initial Created}
* {07 Aug 2023}		{ywibowo}		{Code review}
* {31 Aug 2023}		{sxavier}		{Support recurrence}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[MaintenanceCalendar_Delete] 
(	
	@Id INT
)
AS                        
BEGIN          
	SET NOCOUNT ON
	SET XACT_ABORT ON
		
		BEGIN TRANSACTION

		DELETE FROM
			dbo.MAINTENANCE_CALENDAR_RECURRENCES
		WHERE
			EventId = @Id

		DELETE FROM
			dbo.MAINTENANCE_CALENDAR
		WHERE
			Id = @Id

		COMMIT TRANSACTION

	SET NOCOUNT OFF
END
