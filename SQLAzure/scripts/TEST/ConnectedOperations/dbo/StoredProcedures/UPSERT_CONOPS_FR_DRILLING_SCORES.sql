





/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_FR_DRILLING_SCORES]
* PURPOSE	: Upsert [UPSERT_CONOPS_FR_DRILLING_SCORES]
* NOTES     : 
* CREATED	: mfahmi
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_FR_DRILLING_SCORES] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {20 Feb 2023}		{mfahmi}			{Initial Created}  
* {18 Jul 2023}		{ggosal1}			{Add filter to exclude MINUTE & SECOND <> 0} 
* {26 Jul 2023}		{mfahmi}			{pointing direct to stage table once apply logic for shiftindex on snowflake code} 
*******************************************************************/  
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_FR_DRILLING_SCORES]
AS
BEGIN

DELETE FROM dbo.FR_DRILLING_SCORES

INSERT INTO dbo.FR_DRILLING_SCORES
 SELECT 
 SHIFTINDEX
,SITE_CODE
,DATE
,CASE WHEN SITE_CODE ='CER' THEN (CASE WHEN SHIFT_NAME = 'Noche' THEN 'Night Shift' ELSE 'Day Shift' END )  
ELSE SHIFT_NAME END AS SHIFT_NAME
,CREW_NAME
,OPERATORID
,OPERATORNAME
,PATTERN_NO
,SITE_HOLE_NAME
,HOLENUMBER
,START_HOLE_TS
,END_HOLE_TS
,HOLETIME
,DRILLED
,PENRATE
,GPS_QUALITY
,START_POINT_X
,START_POINT_Y
,START_POINT_Z
,ZACTUALEND
,DESIGN_X_START
,DESIGN_Y_START
,DESIGN_Z_START
,ZPLANEND
,BENCH
,HORIZDIFF
,DEPTH
,PLAN_DEPTH
,DEPTHDIFF
,OVER_DRILLED
,UNDER_DRILLED
,DEPTH_DIFF_FLAG
,HORIZ_DIFF_FLAG
,HORSCORE
,DEPTHSCORE
,OVERALLSCORE
,DRILL_HOLE
,DRILL_BIT_ID
,DRILL_ID
,SOURCE_DRILL_SERIAL_NO
,SOURCE_SYSTEM
,RANK
,HOLEORD
,HOLEORDPATTERN
,WATER_DEPTH
,STEM_HEIGHT
,PROD_1_NAME
,PROD_1_WEIGHT
,UTC_CREATED_DATE
FROM [dbo].[FR_DRILLING_SCORES_STG]
--[dbo].[CONOPS_FR_DRILLING_SCORES_ETL_V] 
--WHERE DATEPART(MINUTE,"DATE") = 0
--	AND DATEPART(SECOND,"DATE") = 0
 
END



