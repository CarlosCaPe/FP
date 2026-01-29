/*****************************************************************************************
* PROCEDURE : usp_Archive_DRILLBLAST_SHIFT_INCR
* PURPOSE   : Archive (delete) records older than @NumberOfDays from DRILLBLAST_SHIFT_INCR
* TABLE     : [dbo].[DRILL_BLAST__DRILLBLAST_SHIFT_INCR]
* INCREMENTAL COLUMN: SHIFT_START_TS_LOCAL (same as Snowflake dynamic table logic)
* DATE: 2026-01-28 | AUTHOR: CARLOS CARRILLO
******************************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[usp_Archive_DRILLBLAST_SHIFT_INCR]
    @NumberOfDays INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowsDeleted INT = 0;
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Delete records older than the retention window
        -- Using SHIFT_START_TS_LOCAL to match Snowflake dynamic table logic
        DELETE FROM [dbo].[DRILL_BLAST__DRILLBLAST_SHIFT_INCR]
        WHERE CAST([SHIFT_START_TS_LOCAL] AS DATE) < @CutoffDate;
        
        SET @RowsDeleted = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        
        SELECT 'SUCCESS' AS Status, 
               @RowsDeleted AS RowsDeleted,
               @CutoffDate AS CutoffDate,
               GETDATE() AS ExecutionTime;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 'ERROR' AS Status,
               ERROR_MESSAGE() AS ErrorMessage,
               ERROR_NUMBER() AS ErrorNumber;
               
        THROW;
    END CATCH
END;
GO
