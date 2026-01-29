/*****************************************************************************************
* PROCEDURE : usp_Archive_All_INCR_Tables
* PURPOSE   : Master procedure to archive (delete) old records from ALL INCR tables
* LOGIC     : Calls all individual archival procedures with the same retention days
* DEFAULT   : 3 days retention (matching Snowflake procedures)
* DATE: 2026-01-28 | AUTHOR: CARLOS CARRILLO
******************************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[usp_Archive_All_INCR_Tables]
    @NumberOfDays INT = 3,
    @PrintResults BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TotalRowsDeleted INT = 0;
    DECLARE @ProcName NVARCHAR(100);
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @StartTime DATETIME2 = GETDATE();
    
    -- Results table
    CREATE TABLE #ArchivalResults (
        ProcedureName NVARCHAR(100),
        TableName NVARCHAR(100),
        RowsDeleted INT,
        Status NVARCHAR(20),
        ErrorMessage NVARCHAR(MAX)
    );
    
    -- List of all archival procedures
    DECLARE @Procedures TABLE (
        ProcName NVARCHAR(100),
        TableName NVARCHAR(100)
    );
    
    INSERT INTO @Procedures VALUES
        ('usp_Archive_BLAST_PLAN_INCR', 'DRILL_BLAST__BLAST_PLAN_INCR'),
        ('usp_Archive_BLAST_PLAN_EXECUTION_INCR', 'DRILL_BLAST__BLAST_PLAN_EXECUTION_INCR'),
        ('usp_Archive_BL_DW_BLAST_INCR', 'DRILL_BLAST__BL_DW_BLAST_INCR'),
        ('usp_Archive_BL_DW_BLASTPROPERTYVALUE_INCR', 'DRILL_BLAST__BL_DW_BLASTPROPERTYVALUE_INCR'),
        ('usp_Archive_BL_DW_HOLE_INCR', 'DRILL_BLAST__BL_DW_HOLE_INCR'),
        ('usp_Archive_DRILLBLAST_EQUIPMENT_INCR', 'DRILL_BLAST__DRILLBLAST_EQUIPMENT_INCR'),
        ('usp_Archive_DRILLBLAST_OPERATOR_INCR', 'DRILL_BLAST__DRILLBLAST_OPERATOR_INCR'),
        ('usp_Archive_DRILLBLAST_SHIFT_INCR', 'DRILL_BLAST__DRILLBLAST_SHIFT_INCR'),
        ('usp_Archive_DRILL_CYCLE_INCR', 'DRILL_BLAST__DRILL_CYCLE_INCR'),
        ('usp_Archive_DRILL_PLAN_INCR', 'DRILL_BLAST__DRILL_PLAN_INCR'),
        ('usp_Archive_LH_HAUL_CYCLE_INCR', 'LOAD_HAUL__LH_HAUL_CYCLE_INCR'),
        ('usp_Archive_LH_EQUIPMENT_STATUS_EVENT_INCR', 'LOAD_HAUL__LH_EQUIPMENT_STATUS_EVENT_INCR'),
        ('usp_Archive_LH_LOADING_CYCLE_INCR', 'LOAD_HAUL__LH_LOADING_CYCLE_INCR'),
        ('usp_Archive_LH_BUCKET_INCR', 'LOAD_HAUL__LH_BUCKET_INCR');
    
    -- Execute each archival procedure
    DECLARE proc_cursor CURSOR FOR
        SELECT ProcName, TableName FROM @Procedures;
    
    DECLARE @TableName NVARCHAR(100);
    DECLARE @RowsDeleted INT;
    
    OPEN proc_cursor;
    FETCH NEXT FROM proc_cursor INTO @ProcName, @TableName;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            -- Check if procedure exists
            IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = @ProcName)
            BEGIN
                SET @SQL = N'EXEC [dbo].[' + @ProcName + N'] @NumberOfDays = ' + CAST(@NumberOfDays AS NVARCHAR(10));
                
                -- Execute and capture results
                CREATE TABLE #TempResult (Status NVARCHAR(20), RowsDeleted INT, CutoffDate DATETIME2, ExecutionTime DATETIME2);
                INSERT INTO #TempResult EXEC sp_executesql @SQL;
                
                SELECT @RowsDeleted = RowsDeleted FROM #TempResult;
                SET @TotalRowsDeleted = @TotalRowsDeleted + ISNULL(@RowsDeleted, 0);
                
                INSERT INTO #ArchivalResults VALUES (@ProcName, @TableName, @RowsDeleted, 'SUCCESS', NULL);
                
                DROP TABLE #TempResult;
            END
            ELSE
            BEGIN
                INSERT INTO #ArchivalResults VALUES (@ProcName, @TableName, 0, 'SKIPPED', 'Procedure does not exist');
            END
        END TRY
        BEGIN CATCH
            INSERT INTO #ArchivalResults VALUES (@ProcName, @TableName, 0, 'ERROR', ERROR_MESSAGE());
        END CATCH
        
        FETCH NEXT FROM proc_cursor INTO @ProcName, @TableName;
    END
    
    CLOSE proc_cursor;
    DEALLOCATE proc_cursor;
    
    -- Return results
    IF @PrintResults = 1
    BEGIN
        SELECT 
            ProcedureName,
            TableName,
            RowsDeleted,
            Status,
            ErrorMessage
        FROM #ArchivalResults
        ORDER BY ProcedureName;
        
        SELECT 
            'SUMMARY' AS ResultType,
            @TotalRowsDeleted AS TotalRowsDeleted,
            @NumberOfDays AS RetentionDays,
            DATEDIFF(SECOND, @StartTime, GETDATE()) AS ExecutionSeconds;
    END
    
    DROP TABLE #ArchivalResults;
    
    RETURN @TotalRowsDeleted;
END;
GO
