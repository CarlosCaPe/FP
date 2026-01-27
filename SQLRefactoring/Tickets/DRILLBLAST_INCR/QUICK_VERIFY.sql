-- ============================================================================
-- QUICK VERIFICATION SCRIPT - Copy/Paste to Snowflake Worksheet
-- Author: Carlos Carrillo / Vikas Review
-- Date: 2026-01-26
-- Purpose: Verify all INCR objects and test purge logic
-- ============================================================================

-- STEP 1: Set context
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEV_API_REF;
USE SCHEMA FUSE;

-- ============================================================================
-- STEP 2: Verify all 11 tables exist
-- ============================================================================

SELECT 'TABLES CHECK' AS STEP, TABLE_NAME, ROW_COUNT
FROM (
    SELECT 'BLAST_PLAN_INCR' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM DEV_API_REF.FUSE.BLAST_PLAN_INCR
    UNION ALL SELECT 'BLAST_PLAN_EXECUTION_INCR', COUNT(*) FROM DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR
    UNION ALL SELECT 'BL_DW_BLAST_INCR', COUNT(*) FROM DEV_API_REF.FUSE.BL_DW_BLAST_INCR
    UNION ALL SELECT 'BL_DW_BLASTPROPERTYVALUE_INCR', COUNT(*) FROM DEV_API_REF.FUSE.BL_DW_BLASTPROPERTYVALUE_INCR
    UNION ALL SELECT 'BL_DW_HOLE_INCR', COUNT(*) FROM DEV_API_REF.FUSE.BL_DW_HOLE_INCR
    UNION ALL SELECT 'DRILL_CYCLE_INCR', COUNT(*) FROM DEV_API_REF.FUSE.DRILL_CYCLE_INCR
    UNION ALL SELECT 'DRILL_PLAN_INCR', COUNT(*) FROM DEV_API_REF.FUSE.DRILL_PLAN_INCR
    UNION ALL SELECT 'DRILLBLAST_EQUIPMENT_INCR', COUNT(*) FROM DEV_API_REF.FUSE.DRILLBLAST_EQUIPMENT_INCR
    UNION ALL SELECT 'DRILLBLAST_OPERATOR_INCR', COUNT(*) FROM DEV_API_REF.FUSE.DRILLBLAST_OPERATOR_INCR
    UNION ALL SELECT 'DRILLBLAST_SHIFT_INCR', COUNT(*) FROM DEV_API_REF.FUSE.DRILLBLAST_SHIFT_INCR
    UNION ALL SELECT 'LH_HAUL_CYCLE_INCR', COUNT(*) FROM DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR
)
ORDER BY TABLE_NAME;

-- ============================================================================
-- STEP 3: Verify all 11 procedures exist
-- ============================================================================

SELECT 'PROCEDURES CHECK' AS STEP, PROCEDURE_NAME
FROM INFORMATION_SCHEMA.PROCEDURES
WHERE PROCEDURE_SCHEMA = 'FUSE'
AND PROCEDURE_NAME LIKE '%_INCR_P'
ORDER BY PROCEDURE_NAME;

-- ============================================================================
-- STEP 4: Test the 5 FIXED procedures (Vikas fix - must show "Purged:")
-- ============================================================================

-- These should return "Purged: X, Merged: Y, Archived: 0"
-- NOT "Deleted: 0, Merged: Y, Archived: 0"

SELECT 'TEST BLAST_PLAN_INCR_P' AS TEST;
CALL DEV_API_REF.FUSE.BLAST_PLAN_INCR_P('7', '90');

SELECT 'TEST DRILL_CYCLE_INCR_P' AS TEST;
CALL DEV_API_REF.FUSE.DRILL_CYCLE_INCR_P('7', '90');

SELECT 'TEST DRILL_PLAN_INCR_P' AS TEST;
CALL DEV_API_REF.FUSE.DRILL_PLAN_INCR_P('7', '90');

SELECT 'TEST DRILLBLAST_SHIFT_INCR_P' AS TEST;
CALL DEV_API_REF.FUSE.DRILLBLAST_SHIFT_INCR_P('7', '90');

SELECT 'TEST LH_HAUL_CYCLE_INCR_P' AS TEST;
CALL DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR_P('7', '90');

-- ============================================================================
-- STEP 5: Test remaining procedures (already had purge logic)
-- ============================================================================

SELECT 'TEST BL_DW_BLAST_INCR_P' AS TEST;
CALL DEV_API_REF.FUSE.BL_DW_BLAST_INCR_P('7');

SELECT 'TEST BL_DW_HOLE_INCR_P' AS TEST;
CALL DEV_API_REF.FUSE.BL_DW_HOLE_INCR_P('7');

SELECT 'TEST DRILLBLAST_EQUIPMENT_INCR_P' AS TEST;
CALL DEV_API_REF.FUSE.DRILLBLAST_EQUIPMENT_INCR_P('7');

SELECT 'TEST DRILLBLAST_OPERATOR_INCR_P' AS TEST;
CALL DEV_API_REF.FUSE.DRILLBLAST_OPERATOR_INCR_P('7');

-- ============================================================================
-- STEP 6: Final summary
-- ============================================================================

SELECT '✅ ALL TESTS COMPLETE' AS STATUS;
SELECT '✅ Vikas Review: All 5 procedures now have purging logic' AS VIKAS_NOTE;
SELECT 'BLAST_PLAN_INCR_P, DRILL_CYCLE_INCR_P, DRILL_PLAN_INCR_P, DRILLBLAST_SHIFT_INCR_P, LH_HAUL_CYCLE_INCR_P' AS FIXED_PROCEDURES;
