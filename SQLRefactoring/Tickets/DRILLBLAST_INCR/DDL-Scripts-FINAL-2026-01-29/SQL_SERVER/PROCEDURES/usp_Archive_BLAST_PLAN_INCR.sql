/*****************************************************************************************
* PROCEDURE : usp_Archive_BLAST_PLAN_INCR
* PURPOSE   : Archive (delete) records older than @NumberOfDays from BLAST_PLAN_INCR
* TABLE     : [dbo].[DRILL_BLAST__BLAST_PLAN_INCR]
* INCREMENTAL COLUMN: BLAST_DT (same as Snowflake dynamic table logic)
* DATE: 2026-01-28 | AUTHOR: CARLOS CARRILLO
******************************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[usp_Archive_BLAST_PLAN_INCR]
    @NumberOfDays INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowsDeleted INT = 0;
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Delete records older than the retention window
        -- Using BLAST_DT to match Snowflake dynamic table logic
        DELETE FROM [dbo].[DRILL_BLAST__BLAST_PLAN_INCR]
        WHERE CAST([BLAST_DT] AS DATE) < @CutoffDate;
        
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
