/*****************************************************************************************
* PROCEDURE : usp_Archive_DRILL_PLAN_INCR
* PURPOSE   : Archive (delete) records older than @NumberOfDays from DRILL_PLAN_INCR
* TABLE     : [dbo].[DRILL_BLAST__DRILL_PLAN_INCR]
* INCREMENTAL COLUMN: DW_MODIFY_TS
* DATE: 2026-01-28 | AUTHOR: CARLOS CARRILLO
******************************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[usp_Archive_DRILL_PLAN_INCR]
    @NumberOfDays INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowsDeleted INT = 0;
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Delete records older than the retention window
        DELETE FROM [dbo].[DRILL_BLAST__DRILL_PLAN_INCR]
        WHERE CAST([DW_MODIFY_TS] AS DATE) < @CutoffDate;
        
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
