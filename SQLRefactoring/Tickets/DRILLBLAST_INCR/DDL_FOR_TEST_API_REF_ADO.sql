/*
================================================================================
DRILLBLAST_INCR Objects - DDL for TEST_API_REF.FUSE
================================================================================
Generated: 2026-01-26T15:21:31.685737
Purpose: Complete DDL scripts for Azure DevOps deployment to TEST environment

Objects:
  - 11 Tables (CREATE TABLE with full column definitions)
  - 11 Stored Procedures (CREATE PROCEDURE)

Instructions:
  1. Deploy tables first (Section 1)
  2. Deploy procedures second (Section 2)
  3. Run initial load: CALL <procedure_name>('30');
================================================================================
*/

USE DATABASE TEST_API_REF;
USE SCHEMA FUSE;
USE WAREHOUSE WH_BATCH_DE_NONPROD;

-- ============================================================================
-- SECTION 1: TABLE DDL (11 Tables)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TABLE: BL_DW_BLAST_INCR
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS TEST_API_REF.FUSE.BL_DW_BLAST_INCR;

create or replace TABLE BL_DW_BLAST_INCR (
	ORIG_SRC_ID NUMBER(19,0) NOT NULL,
	SITE_CODE VARCHAR(50) NOT NULL COLLATE 'en-ci',
	ID NUMBER(10,0) NOT NULL,
	NAME VARCHAR(1000) COLLATE 'en-ci',
	STATUS VARCHAR(20) COLLATE 'en-ci',
	FIREDTIME TIMESTAMP_NTZ(9),
	ABANDONEDTIME TIMESTAMP_NTZ(9),
	ABANDONEDCOMMENT VARCHAR(5000) COLLATE 'en-ci',
	SUSPENDEDTIME TIMESTAMP_NTZ(9),
	SUSPENDEDCOMMENT VARCHAR(5000) COLLATE 'en-ci',
	VOLUME FLOAT,
	HOLECOUNT NUMBER(10,0),
	SHOTFIRERNAME VARCHAR(500) COLLATE 'en-ci',
	REFRESHEDTIME TIMESTAMP_NTZ(9),
	DELETED BOOLEAN,
	DW_FILE_TS_UTC TIMESTAMP_NTZ(9),
	DW_LOGICAL_DELETE_FLAG VARCHAR(1) COLLATE 'en-ci' DEFAULT 'N',
	DW_LOAD_TS TIMESTAMP_NTZ(0),
	DW_MODIFY_TS TIMESTAMP_NTZ(0)
)COMMENT='Incremental table for BL_DW_BLAST - MERGE-driven upserts with 3-day incremental window'
;;

-- ----------------------------------------------------------------------------
-- TABLE: BL_DW_BLASTPROPERTYVALUE_INCR
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS TEST_API_REF.FUSE.BL_DW_BLASTPROPERTYVALUE_INCR;

create or replace TABLE BL_DW_BLASTPROPERTYVALUE_INCR (
	ORIG_SRC_ID NUMBER(19,0) NOT NULL,
	SITE_CODE VARCHAR(50) NOT NULL COLLATE 'en-ci',
	BLASTID NUMBER(10,0) NOT NULL,
	REFRESHEDTIME TIMESTAMP_NTZ(9),
	DELETED BOOLEAN,
	PARAMETER VARCHAR(400) COLLATE 'en-ci',
	PLANNEDDATE VARCHAR(400) COLLATE 'en-ci',
	SHOTTYPE VARCHAR(400) COLLATE 'en-ci',
	SHOTGOAL VARCHAR(400) COLLATE 'en-ci',
	DW_FILE_TS_UTC TIMESTAMP_NTZ(9),
	DW_LOGICAL_DELETE_FLAG VARCHAR(1) COLLATE 'en-ci' DEFAULT 'N',
	DW_LOAD_TS TIMESTAMP_NTZ(0),
	DW_MODIFY_TS TIMESTAMP_NTZ(0)
)COMMENT='Incremental table for BL_DW_BLASTPROPERTYVALUE'
;;

-- ----------------------------------------------------------------------------
-- TABLE: BL_DW_HOLE_INCR
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS TEST_API_REF.FUSE.BL_DW_HOLE_INCR;

create or replace TABLE BL_DW_HOLE_INCR (
	ORIG_SRC_ID NUMBER(19,0) NOT NULL,
	SITE_CODE VARCHAR(50) NOT NULL COLLATE 'en-ci',
	ID NUMBER(10,0) NOT NULL,
	NAME VARCHAR(500) COLLATE 'en-ci',
	MODIFIED_NAME VARCHAR(500) COLLATE 'en-ci',
	BLASTNAME VARCHAR(500) COLLATE 'en-ci',
	MODIFIED_BLASTNAME VARCHAR(500) COLLATE 'en-ci',
	BLASTID NUMBER(10,0),
	"ROW" VARCHAR(500) COLLATE 'en-ci',
	ECHELON NUMBER(10,0),
	STATUS VARCHAR(500) COLLATE 'en-ci',
	LASTKNOWNDEPTH FLOAT,
	LASTKNOWNWATER FLOAT,
	LASTKNOWNWETSIDES FLOAT,
	LASTKNOWNTEMPERATURE FLOAT,
	LASTKNOWNTEMPERATURETIME TIMESTAMP_NTZ(9),
	PREVIOUSTEMPERATURE FLOAT,
	PREVIOUSTEMPERATURETIME TIMESTAMP_NTZ(9),
	TEMPERATURERATEOFCHANGE FLOAT,
	DESIGNTIME TIMESTAMP_NTZ(9),
	DRILLEDTIME TIMESTAMP_NTZ(9),
	LASTDIPDEPTH FLOAT,
	LASTDIPPEDTIME TIMESTAMP_NTZ(9),
	LASTBACKFILLINGDIPDEPTH FLOAT,
	LASTBACKFILLINGDIPTIME TIMESTAMP_NTZ(9),
	LASTCHARGINGDIPDEPTH FLOAT,
	LASTCHARGINGDIPTIME TIMESTAMP_NTZ(9),
	CHARGEDTIME TIMESTAMP_NTZ(9),
	FIREDTIME TIMESTAMP_NTZ(9),
	ABANDONEDTIME TIMESTAMP_NTZ(9),
	ABANDONEDCOMMENT VARCHAR(5000) COLLATE 'en-ci',
	MISFIRE BOOLEAN,
	MISFIRECOMMENT VARCHAR(5000) COLLATE 'en-ci',
	REDRILLOFHOLEID NUMBER(10,0),
	REDRILLOFHOLENAME VARCHAR(500) COLLATE 'en-ci',
	ISADHOC BOOLEAN,
	DESIGNCOLLARX FLOAT,
	DESIGNCOLLARY FLOAT,
	DESIGNCOLLARZ FLOAT,
	DESIGNANGLE FLOAT,
	DESIGNBEARING FLOAT,
	DESIGNDEPTH FLOAT,
	DESIGNDIAMETER FLOAT,
	DESIGNBURDEN FLOAT,
	DESIGNSPACING FLOAT,
	ACTUALCOLLARX FLOAT,
	ACTUALCOLLARY FLOAT,
	ACTUALCOLLARZ FLOAT,
	TARGETCHARGEDEPTH FLOAT,
	PLANNEDPRIMERCOUNT NUMBER(10,0),
	LOADEDPRIMERCOUNT NUMBER(10,0),
	LOADEDEXPLOSIVEDECKCOUNT NUMBER(10,0),
	DIPPEDOUTSIDECHARGEDEPTHTOLERANCE BOOLEAN,
	CHARGEDOUTSIDEMASSTOLERANCE BOOLEAN,
	DRILLEDOUTSIDECOLLARTOLERANCE BOOLEAN,
	TOPMOSTSTEMMINGDECKLOADED BOOLEAN,
	STEMMEDOUTSIDELENGTHTOLERANCE BOOLEAN,
	EXPLOSIVEMASSDESIGNED FLOAT,
	EXPLOSIVEMASSLOADED FLOAT,
	EXPLOSIVEMASSRECONCILED FLOAT,
	STEMMINGLENGTHDESIGNED FLOAT,
	STEMMINGLENGTHLOADED FLOAT,
	STEMMINGLENGTHRECONCILED FLOAT,
	DESIGNTIEUPCOUNT NUMBER(10,0),
	ACTUALTIEUPCOUNT NUMBER(10,0),
	DESIGNDRILLCOST NUMBER(15,5),
	CHARGESTANDOFF FLOAT,
	CHARGESTANDOFFDIRECTION VARCHAR(50) COLLATE 'en-ci',
	REFRESHEDTIME TIMESTAMP_NTZ(9),
	DELETED BOOLEAN,
	DW_FILE_TS_UTC TIMESTAMP_NTZ(9),
	DW_LOGICAL_DELETE_FLAG VARCHAR(1) COLLATE 'en-ci' DEFAULT 'N',
	DW_LOAD_TS TIMESTAMP_NTZ(0),
	DW_MODIFY_TS TIMESTAMP_NTZ(0)
)COMMENT='Incremental table for BL_DW_HOLE - Drill hole details within blasts'
;;

-- ----------------------------------------------------------------------------
-- TABLE: BLAST_PLAN_INCR
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS TEST_API_REF.FUSE.BLAST_PLAN_INCR;

create or replace TABLE BLAST_PLAN_INCR (
	BLAST_PLAN_SK NUMBER(38,0) NOT NULL,
	ORIG_SRC_ID NUMBER(38,0),
	SITE_CODE VARCHAR(50),
	BENCH FLOAT,
	PUSHBACK VARCHAR(5000),
	PATTERN_NAME VARCHAR(510),
	BLAST_NAME VARCHAR(5000),
	PLAN_CREATION_TS_UTC VARCHAR(50),
	PLAN_CREATION_TS_LOCAL VARCHAR(50),
	DESIGN_BY VARCHAR(500),
	DRILL_CYCLE_SK NUMBER(38,0),
	BLAST_ID NUMBER(38,0),
	DRILLED_HOLE_ID NUMBER(38,0),
	BLAST_TYPE VARCHAR(400),
	BLAST_GOAL VARCHAR(400),
	BLAST_DATE_UTC VARCHAR(50),
	DRILLED_HOLE_NAME VARCHAR(500),
	DRILLED_HOLE_FLAG BOOLEAN,
	HOLE_START_METERS_X FLOAT,
	HOLE_START_METERS_Y FLOAT,
	HOLE_START_METERS_Z FLOAT,
	HOLE_START_FEET_X FLOAT,
	HOLE_START_FEET_Y FLOAT,
	HOLE_START_FEET_Z FLOAT,
	DEPTH_METERS FLOAT,
	DEPTH_FEET FLOAT,
	CHARGE_RULE_NAME VARCHAR(100),
	EXPLOSIVE_PRODUCT_BOTTOM NUMBER(38,0),
	EXPLOSIVE_PRODUCT_TOP NUMBER(38,0),
	EXPLOSIVE_PRODUCT_COUNT NUMBER(38,0),
	EXPLOSIVE_PRODUCT_USED_BOTTOM_KILOGRAMS FLOAT,
	EXPLOSIVE_PRODUCT_USED_BOTTOM_POUNDS FLOAT,
	EXPLOSIVE_PRODUCT_USED_TOP_KILOGRAMS FLOAT,
	EXPLOSIVE_PRODUCT_USED_TOP_POUNDS FLOAT,
	EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_METERS FLOAT,
	EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_FEET FLOAT,
	EXPLOSIVE_PRODUCT_LENGTH_TOP_METERS FLOAT,
	EXPLOSIVE_PRODUCT_LENGTH_TOP_FEET FLOAT,
	STEMMING_LENGTH_TOTAL_METERS FLOAT,
	STEMMING_LENGTH_TOTAL_FEET FLOAT,
	STEMMING_LENGTH_BOTTOM_METERS FLOAT,
	STEMMING_LENGTH_BOTTOM_FEET FLOAT,
	STEMMING_LENGTH_TOP_METERS FLOAT,
	STEMMING_LENGTH_TOP_FEET FLOAT,
	AIR_BAG_ELEVATION_METERS FLOAT,
	AIR_BAG_ELEVATION_FEET FLOAT,
	AIR_BAG_FLAG BOOLEAN,
	AIR_ELEVATION_METERS FLOAT,
	AIR_ELEVATION_FEET FLOAT,
	AIR_FLAG BOOLEAN,
	BURDEN_METERS FLOAT,
	BURDEN_FEET FLOAT,
	SPACING_METERS FLOAT,
	SPACING_FEET FLOAT,
	TONS_PER_HOLE FLOAT,
	HOLE_REMOVED_FLAG BOOLEAN,
	KCALS_PER_TON FLOAT,
	POWDER_FACTOR FLOAT,
	MEGAJOULES_PER_TON FLOAT,
	CONFINEMENT_FACTOR FLOAT,
	TIMING_RATIO FLOAT,
	TARGET_P80 FLOAT,
	REACTIVE_GROUND_FLAG NUMBER(18,5),
	PRIMER_COUNT NUMBER(38,0),
	DW_LOAD_TS TIMESTAMP_NTZ(9),
	DW_MODIFY_TS TIMESTAMP_NTZ(9),
	DW_LOGICAL_DELETE_FLAG VARCHAR(1) DEFAULT 'N',
	DW_ROW_HASH VARCHAR(64),
	constraint PK_BLAST_PLAN_INCR primary key (BLAST_PLAN_SK)
);;

-- ----------------------------------------------------------------------------
-- TABLE: BLAST_PLAN_EXECUTION_INCR
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS TEST_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR;

create or replace TABLE BLAST_PLAN_EXECUTION_INCR (
	ORIG_SRC_ID NUMBER(38,0) NOT NULL,
	SITE_CODE VARCHAR(50) NOT NULL,
	BENCH FLOAT NOT NULL,
	PUSHBACK VARCHAR(50) NOT NULL,
	PATTERN_NAME VARCHAR(400) NOT NULL,
	BLAST_NAME VARCHAR(5000) NOT NULL,
	DRILLED_HOLE_ID NUMBER(38,0) NOT NULL,
	DRILLED_HOLE_NAME VARCHAR(500),
	DRILL_CYCLE_SK NUMBER(38,0),
	BLAST_PLAN_SK NUMBER(38,0),
	SHIFT_ID VARCHAR(500),
	BLAST_ID NUMBER(38,0),
	SHOT_DATE_UTC VARCHAR(50),
	SHOT_DATE_LOCAL VARCHAR(50),
	BLAST_TYPE VARCHAR(400),
	BLAST_ENGINEER_NAME VARCHAR(500),
	LOADING_TRUCK_OPERATOR_NAME VARCHAR(200),
	HOLE_LOADED_TS_UTC VARCHAR(50),
	HOLE_LOADED_TS_LOCAL VARCHAR(50),
	HOLE_LAST_KNOWN_DEPTH_METERS NUMBER(38,5),
	HOLE_LAST_KNOWN_DEPTH_FEET NUMBER(38,5),
	HOLE_TAPED_DEPTH_METERS NUMBER(38,5),
	HOLE_TAPED_DEPTH_FEET NUMBER(38,5),
	HOLE_PLUGGED_FLAG BOOLEAN,
	EXPLOSIVE_PRODUCT_BOTTOM NUMBER(38,0),
	EXPLOSIVE_PRODUCT_TOP NUMBER(38,0),
	EXPLOSIVE_PRODUCT_USED_BOTTOM_KILOGRAMS NUMBER(38,5),
	EXPLOSIVE_PRODUCT_USED_BOTTOM_POUNDS NUMBER(38,5),
	EXPLOSIVE_PRODUCT_USED_TOP_KILOGRAMS NUMBER(38,5),
	EXPLOSIVE_PRODUCT_USED_TOP_POUNDS NUMBER(38,5),
	EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_METERS NUMBER(38,5),
	EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_FEET NUMBER(38,5),
	EXPLOSIVE_PRODUCT_LENGTH_TOP_METERS NUMBER(38,5),
	EXPLOSIVE_PRODUCT_LENGTH_TOP_FEET NUMBER(38,5),
	STEMMING_LENGTH_TOTAL_METERS NUMBER(38,5),
	STEMMING_LENGTH_TOTAL_FEET NUMBER(38,5),
	STEMMING_LENGTH_BOTTOM_METERS NUMBER(38,5),
	STEMMING_LENGTH_BOTTOM_FEET NUMBER(38,5),
	STEMMING_LENGTH_TOP_METERS NUMBER(38,5),
	STEMMING_LENGTH_TOP_FEET NUMBER(38,5),
	BURDEN_METERS NUMBER(38,5),
	BURDEN_FEET NUMBER(38,5),
	SPACING_METERS NUMBER(38,5),
	SPACING_FEET NUMBER(38,5),
	TONS_PER_HOLE NUMBER(38,5),
	KCALS_PER_TON NUMBER(38,5),
	POWDER_FACTOR NUMBER(38,5),
	MEGAJOULES_PER_TON NUMBER(38,5),
	CONFINEMENT_FACTOR NUMBER(38,5),
	PRIMER_COUNT NUMBER(38,0),
	HOLE_TEMPERATURE_CELSIUS NUMBER(38,5),
	HOLE_TEMPERATURE_FAHRENHEIT NUMBER(38,5),
	PRODUCT_BOTTOM_COMMENTS VARCHAR(5000),
	PRODUCT_TOP_COMMENTS VARCHAR(5000),
	STEMMING_BOTTOM_COMMENT VARCHAR(5000),
	STEMMING_TOP_COMMENT VARCHAR(5000),
	WATER_DEPTH_METERS NUMBER(38,5),
	WATER_DEPTH_FEET NUMBER(38,5),
	MISFIRE_FLAG BOOLEAN,
	DW_LOAD_TS TIMESTAMP_NTZ(9),
	DW_MODIFY_TS TIMESTAMP_NTZ(9),
	DW_LOGICAL_DELETE_FLAG VARCHAR(1) DEFAULT 'N',
	DW_ROW_HASH VARCHAR(64),
	constraint PK_BLAST_PLAN_EXECUTION_INCR primary key (ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME, DRILLED_HOLE_ID)
);;

-- ----------------------------------------------------------------------------
-- TABLE: DRILL_CYCLE_INCR
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS TEST_API_REF.FUSE.DRILL_CYCLE_INCR;

create or replace TABLE DRILL_CYCLE_INCR (
	DRILL_CYCLE_SK NUMBER(38,0) NOT NULL,
	ORIG_SRC_ID NUMBER(38,0),
	SITE_CODE VARCHAR(5),
	BENCH VARCHAR(5000),
	PUSHBACK VARCHAR(500),
	PATTERN_NAME VARCHAR(500),
	ORIGINAL_PATTERN_NAME VARCHAR(500),
	DRILL_HOLE_SHIFT_ID VARCHAR(500),
	DRILL_ID NUMBER(38,0),
	DRILL_BIT_ID VARCHAR(255),
	SYSTEM_OPERATOR_ID VARCHAR(50),
	DRILL_HOLE_ID VARCHAR(500),
	DRILL_HOLE_NAME VARCHAR(500),
	DRILL_PLAN_SK NUMBER(38,0),
	DRILL_HOLE_STATUS NUMBER(38,0),
	IS_HOLE_PLANNED_FLAG NUMBER(38,0),
	START_HOLE_TS_UTC VARCHAR(50),
	END_HOLE_TS_UTC VARCHAR(50),
	OPERATOR_LOGIN_TS_UTC VARCHAR(50),
	OPERATOR_LOGOUT_TS_UTC VARCHAR(50),
	PROPEL_START_TS_UTC VARCHAR(50),
	PROPEL_END_TS_UTC VARCHAR(50),
	PARK_POSITION_START_TS_UTC VARCHAR(50),
	PARK_POSITION_END_TS_UTC VARCHAR(50),
	LEVEL_START_TS_UTC VARCHAR(50),
	LEVEL_END_TS_UTC VARCHAR(50),
	DRILL_START_TS_UTC VARCHAR(50),
	DRILL_END_TS_UTC VARCHAR(50),
	RETRACT_START_TS_UTC VARCHAR(50),
	RETRACT_END_TS_UTC VARCHAR(50),
	START_HOLE_TS_LOCAL VARCHAR(50),
	END_HOLE_TS_LOCAL VARCHAR(50),
	OPERATOR_LOGIN_TS_LOCAL VARCHAR(50),
	OPERATOR_LOGOUT_TS_LOCAL VARCHAR(50),
	PROPEL_START_TS_LOCAL VARCHAR(50),
	PROPEL_END_TS_LOCAL VARCHAR(50),
	PARK_POSITION_START_TS_LOCAL VARCHAR(50),
	PARK_POSITION_END_TS_LOCAL VARCHAR(50),
	LEVEL_START_TS_LOCAL VARCHAR(50),
	LEVEL_END_TS_LOCAL VARCHAR(50),
	DRILL_START_TS_LOCAL VARCHAR(50),
	DRILL_END_TS_LOCAL VARCHAR(50),
	RETRACT_START_TS_LOCAL VARCHAR(50),
	RETRACT_END_TS_LOCAL VARCHAR(50),
	PLAN_CREATION_TS_LOCAL VARCHAR(50),
	DRILL_HOLE_DURATION_SECONDS NUMBER(38,0),
	AUTODRILL_DURATION_SECONDS NUMBER(38,0),
	TIME_BETWEEN_DRILL_HOLES_SECONDS NUMBER(38,0),
	SYSTEM_DRILL_STATE_DURATION_SECONDS NUMBER(38,0),
	SYSTEM_SETUP_STATE_DURATION_SECONDS NUMBER(38,0),
	SYSTEM_AUTO_LEVEL_DURATION_SECONDS NUMBER(38,0),
	SYSTEM_AUTO_DELEVEL_DURATION_SECONDS NUMBER(38,0),
	PROPEL_DURATION NUMBER(36,6),
	PARK_POSITION_DURATION NUMBER(36,6),
	LEVEL_DURATION NUMBER(36,6),
	DRILL_DURATION NUMBER(36,6),
	RETRACT_DURATION NUMBER(36,6),
	ACTUAL_DRILL_HOLE_DEPTH_FEET NUMBER(38,5),
	ACTUAL_DRILL_HOLE_DEPTH_METERS NUMBER(38,5),
	ACTUAL_DRILL_HOLE_START_FEET_X NUMBER(38,5),
	ACTUAL_DRILL_HOLE_START_FEET_Y NUMBER(38,5),
	ACTUAL_DRILL_HOLE_START_FEET_Z NUMBER(38,5),
	ACTUAL_DRILL_HOLE_END_FEET_X NUMBER(38,5),
	ACTUAL_DRILL_HOLE_END_FEET_Y NUMBER(38,5),
	ACTUAL_DRILL_HOLE_END_FEET_Z NUMBER(38,5),
	ACTUAL_DRILL_HOLE_START_METERS_X NUMBER(38,5),
	ACTUAL_DRILL_HOLE_START_METERS_Y NUMBER(38,5),
	ACTUAL_DRILL_HOLE_START_METERS_Z NUMBER(38,5),
	ACTUAL_DRILL_HOLE_END_METERS_X NUMBER(38,5),
	ACTUAL_DRILL_HOLE_END_METERS_Y NUMBER(38,5),
	ACTUAL_DRILL_HOLE_END_METERS_Z NUMBER(38,5),
	GPS_ACCURACY NUMBER(38,0),
	ACTUAL_DRILL_HOLE_LONGITUDE FLOAT,
	ACTUAL_DRILL_HOLE_LATITUDE FLOAT,
	AUTODRILL_USAGE_PCT NUMBER(38,0),
	DRILL_HOLE_PENETRATION_RATE_AVG_FEET_HOUR NUMBER(38,5),
	INSTANTANOUS_PENRATE_MWD_METERS_HOUR NUMBER(38,5),
	INSTANTANOUS_PENRATE_MWD_FEET_HOUR NUMBER(38,5),
	BEARING NUMBER(38,1),
	DRILL_TOWER_ANGLE_DEGREE_CALCULATED NUMBER(38,5),
	DRILL_TOWER_ANGLE_DEGREE_SYSTEM NUMBER(38,5),
	DRILL_HOLE_DUPLICATED_FLAG NUMBER(38,0),
	DRILL_HOLE_UPSIDE_DOWN_FLAG NUMBER(38,0),
	DRILL_HOLE_START_END_TIME_INVALID_FLAG NUMBER(38,0),
	DRILL_HOLE_START_END_TIME_OVERLAP_FLAG NUMBER(38,0),
	DRILL_HOLE_DEPTH_INVALID_FLAG NUMBER(38,0),
	DRILL_HOLE_ANGLE_INVALID_FLAG NUMBER(38,0),
	DRILL_HOLE_POSITION_INVALID_FLAG NUMBER(38,0),
	DRILL_HOLE_OFF_TARGET_FEET NUMBER(38,5),
	DRILL_HOLE_OFF_TARGET_METERS NUMBER(38,5),
	DRILL_HOLE_HORIZONTAL_ACCURACY_PCT NUMBER(38,0),
	DRILL_HOLE_VERTICAL_ACCURACY_PCT NUMBER(38,0),
	OVERDRILL_UNDERDRILL_FLAG BOOLEAN,
	OVERDRILL_UNDERDRILL_FEET NUMBER(38,5),
	OVERDRILL_UNDERDRILL_METERS NUMBER(38,5),
	DRILLING_STOPS_COUNT NUMBER(38,0),
	DRILL_HOLE_REDRILL_FLAG NUMBER(38,0),
	AIR_PRESSURE_PSI NUMBER(38,5),
	FEED_FORCE_NEWTONS NUMBER(38,5),
	ROTATION_TORQUE_NM NUMBER(38,5),
	BIT_SPEED_RPM NUMBER(38,5),
	WATER_FLOW_GPM NUMBER(38,5),
	ACTUAL_MCF_BLOCK_ID VARCHAR(5000),
	DESIGN_MCF_BLOCK_ID VARCHAR(5000),
	SYSTEM_VERSION VARCHAR(11),
	DW_LOAD_TS TIMESTAMP_NTZ(9),
	DW_MODIFY_TS TIMESTAMP_NTZ(9),
	DW_LOGICAL_DELETE_FLAG VARCHAR(1) DEFAULT 'N',
	DW_ROW_HASH VARCHAR(64),
	constraint PK_DRILL_CYCLE_INCR primary key (DRILL_CYCLE_SK)
);;

-- ----------------------------------------------------------------------------
-- TABLE: DRILL_PLAN_INCR
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS TEST_API_REF.FUSE.DRILL_PLAN_INCR;

create or replace TABLE DRILL_PLAN_INCR (
	DRILL_PLAN_SK NUMBER(38,0) NOT NULL,
	ORIG_SRC_ID NUMBER(38,0),
	SITE_CODE VARCHAR(5),
	BENCH NUMBER(38,1),
	PUSHBACK VARCHAR(5000),
	PATTERN_NAME VARCHAR(510),
	ORIGINAL_PATTERN_NAME VARCHAR(510),
	PLAN_CREATION_TS_UTC VARCHAR(50),
	PLAN_CREATION_TS_LOCAL VARCHAR(50),
	DESIGN_BY VARCHAR(100),
	HOLE_NAME VARCHAR(256),
	HOLE_DIAMETER_MM NUMBER(38,5),
	HOLE_DIAMETER_INCHES NUMBER(38,5),
	HOLE_DEPTH_METERS NUMBER(38,5),
	HOLE_DEPTH_FEET NUMBER(38,5),
	HOLE_START_METERS_X NUMBER(38,5),
	HOLE_START_METERS_Y NUMBER(38,5),
	HOLE_START_METERS_Z NUMBER(38,5),
	HOLE_END_METERS_X NUMBER(38,5),
	HOLE_END_METERS_Y NUMBER(38,5),
	HOLE_END_METERS_Z NUMBER(38,5),
	HOLE_START_FEET_X NUMBER(38,5),
	HOLE_START_FEET_Y NUMBER(38,5),
	HOLE_START_FEET_Z NUMBER(38,5),
	HOLE_END_FEET_X NUMBER(38,5),
	HOLE_END_FEET_Y NUMBER(38,5),
	HOLE_END_FEET_Z NUMBER(38,5),
	BURDEN FLOAT,
	SPACING FLOAT,
	TONS_PER_HOLE VARCHAR(5000),
	BLASTABILITY_INDEX VARCHAR(5000),
	RQD VARCHAR(5000),
	UCS VARCHAR(5000),
	PREDICTED_PENRATE VARCHAR(5000),
	PROJECTED_MECHANICAL_SPECIFIC_ENERGY VARCHAR(5000),
	TARGET_P80 VARCHAR(5000),
	SHOT_GOAL VARCHAR(5000),
	SYSTEM_VERSION VARCHAR(20),
	DW_LOAD_TS TIMESTAMP_NTZ(9),
	DW_MODIFY_TS TIMESTAMP_NTZ(9),
	DW_LOGICAL_DELETE_FLAG VARCHAR(1) DEFAULT 'N',
	DW_ROW_HASH VARCHAR(64),
	constraint PK_DRILL_PLAN_INCR primary key (DRILL_PLAN_SK)
);;

-- ----------------------------------------------------------------------------
-- TABLE: DRILLBLAST_EQUIPMENT_INCR
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS TEST_API_REF.FUSE.DRILLBLAST_EQUIPMENT_INCR;

create or replace TABLE DRILLBLAST_EQUIPMENT_INCR (
	ORIG_SRC_ID NUMBER(10,0) NOT NULL,
	SITE_CODE VARCHAR(5) NOT NULL COLLATE 'en-ci',
	DRILL_ID NUMBER(19,0) NOT NULL,
	EQUIP_NAME VARCHAR(255) COLLATE 'en-ci',
	EQUIP_MODEL VARCHAR(255) COLLATE 'en-ci',
	SERIAL_NUMBER VARCHAR(255) COLLATE 'en-ci',
	EQUIP_CATEGORY VARCHAR(50) COLLATE 'en-ci',
	MEM_EQUIP_ID VARCHAR(255) COLLATE 'en-ci',
	EQUIP_UNIT_CODE NUMBER(10,0),
	SAP_EQUIP_NO VARCHAR(50) COLLATE 'en-ci',
	SYSTEM_VERSION VARCHAR(255) COLLATE 'en-ci',
	DW_LOGICAL_DELETE_FLAG VARCHAR(1) COLLATE 'en-ci' DEFAULT 'N',
	DW_LOAD_TS TIMESTAMP_NTZ(0),
	DW_MODIFY_TS TIMESTAMP_NTZ(0)
)COMMENT='Incremental table for DRILLBLAST_EQUIPMENT'
;;

-- ----------------------------------------------------------------------------
-- TABLE: DRILLBLAST_OPERATOR_INCR
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS TEST_API_REF.FUSE.DRILLBLAST_OPERATOR_INCR;

create or replace TABLE DRILLBLAST_OPERATOR_INCR (
	SYSTEM_OPERATOR_ID NUMBER(19,0) NOT NULL,
	SITE_CODE VARCHAR(5) NOT NULL COLLATE 'en-ci',
	ORIG_SRC_ID NUMBER(10,0),
	APPLICATION_OPERATOR_ID VARCHAR(255) COLLATE 'en-ci',
	OPERATOR_NAME VARCHAR(255) COLLATE 'en-ci',
	CREW_ID NUMBER(10,0),
	CREW_NAME VARCHAR(255) COLLATE 'en-ci',
	SAP_OPERATOR_ID VARCHAR(255) COLLATE 'en-ci',
	EFFECTIVE_START_DATE TIMESTAMP_NTZ(9),
	END_DATE TIMESTAMP_NTZ(9),
	SYSTEM_VERSION VARCHAR(255) COLLATE 'en-ci',
	DW_LOGICAL_DELETE_FLAG VARCHAR(1) COLLATE 'en-ci' DEFAULT 'N',
	DW_LOAD_TS TIMESTAMP_NTZ(0),
	DW_MODIFY_TS TIMESTAMP_NTZ(0)
)COMMENT='Incremental table for DRILLBLAST_OPERATOR'
;;

-- ----------------------------------------------------------------------------
-- TABLE: DRILLBLAST_SHIFT_INCR
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS TEST_API_REF.FUSE.DRILLBLAST_SHIFT_INCR;

create or replace TABLE DRILLBLAST_SHIFT_INCR (
	ORIG_SRC_ID NUMBER(10,0),
	SITE_CODE VARCHAR(5) NOT NULL COLLATE 'en-ci',
	SHIFT_ID VARCHAR(500) NOT NULL COLLATE 'en-ci',
	SHIFT_DATE DATE,
	SHIFT_NAME VARCHAR(255) COLLATE 'en-ci',
	SHIFT_DATE_NAME VARCHAR(255) COLLATE 'en-ci',
	ATTRIBUTED_CREW_ID NUMBER(19,0),
	CREW_NAME VARCHAR(255) COLLATE 'en-ci',
	SHIFT_NO NUMBER(10,0),
	SHIFT_START_TS_UTC TIMESTAMP_NTZ(9),
	SHIFT_END_TS_UTC TIMESTAMP_NTZ(9),
	SHIFT_START_TS_LOCAL TIMESTAMP_NTZ(9),
	SHIFT_END_TS_LOCAL TIMESTAMP_NTZ(9),
	SYSTEM_VERSION VARCHAR(50) COLLATE 'en-ci',
	DW_LOGICAL_DELETE_FLAG VARCHAR(1) COLLATE 'en-ci' DEFAULT 'N',
	DW_LOAD_TS TIMESTAMP_NTZ(0),
	DW_MODIFY_TS TIMESTAMP_NTZ(0)
)COMMENT='Incremental table for DRILLBLAST_SHIFT'
;;

-- ----------------------------------------------------------------------------
-- TABLE: LH_HAUL_CYCLE_INCR
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS TEST_API_REF.FUSE.LH_HAUL_CYCLE_INCR;

create or replace TABLE LH_HAUL_CYCLE_INCR (
	HAUL_CYCLE_ID NUMBER(19,0) NOT NULL,
	SITE_CODE VARCHAR(4) COLLATE 'en-ci',
	ORIG_SRC_ID NUMBER(38,0),
	SHIFT_ID_AT_LOADING_END VARCHAR(12) COLLATE 'en-ci',
	SHIFT_ID_AT_DUMP_END VARCHAR(12) COLLATE 'en-ci',
	MATERIAL_ID NUMBER(19,0),
	ROUTING_SHAPE_ID NUMBER(19,0),
	LOADING_LOC_ID NUMBER(19,0),
	LOADING_LOC_NAME VARCHAR(255) COLLATE 'en-ci',
	LOADING_LOC_COORD_X FLOAT,
	LOADING_LOC_COORD_Y FLOAT,
	LOADING_LOC_ELEV FLOAT,
	LOADING_METHOD VARCHAR(50) COLLATE 'en-ci',
	DUMP_LOC_ID NUMBER(19,0),
	DUMP_LOC_NAME VARCHAR(255) COLLATE 'en-ci',
	DUMP_LOC_COORD_X FLOAT,
	DUMP_LOC_COORD_Y FLOAT,
	DUMP_LOC_ELEV FLOAT,
	CATEGORY_MATERIAL VARCHAR(50) COLLATE 'en-ci',
	CATEGORY_SOURCE_DESTINATION VARCHAR(100) COLLATE 'en-ci',
	EXCAV_ID NUMBER(19,0),
	EXCAV_OPERATOR_ID NUMBER(19,0),
	TRUCK_ID NUMBER(19,0),
	TRUCK_LOADING_OPERATOR_ID NUMBER(19,0),
	TRUCK_DUMPING_OPERATOR_ID NUMBER(19,0),
	REPORT_PAYLOAD_SHORT_TONS NUMBER(38,6),
	NOMINAL_PAYLOAD_SHORT_TONS NUMBER(38,6),
	MEASURED_PAYLOAD_METRIC_TONS NUMBER(38,6),
	AUTONOMOUS_FLAG NUMBER(1,0),
	OVERLOAD_FLAG NUMBER(1,0),
	CYCLE_START_TS_UTC TIMESTAMP_NTZ(3),
	CYCLE_END_TS_UTC TIMESTAMP_NTZ(3),
	CYCLE_START_TS_LOCAL TIMESTAMP_NTZ(3),
	CYCLE_END_TS_LOCAL TIMESTAMP_NTZ(3),
	EMPTY_TRAVEL_START_TS_UTC TIMESTAMP_NTZ(3),
	EMPTY_TRAVEL_END_TS_UTC TIMESTAMP_NTZ(3),
	EMPTY_TRAVEL_START_TS_LOCAL TIMESTAMP_NTZ(3),
	EMPTY_TRAVEL_END_TS_LOCAL TIMESTAMP_NTZ(3),
	EMPTY_TRAVEL_DURATION_MINS NUMBER(38,6),
	EMPTY_TRAVEL_DISTANCE_FEET NUMBER(38,6),
	EMPTY_TRAVEL_DISTANCE_METERS NUMBER(38,6),
	LOADING_START_TS_UTC TIMESTAMP_NTZ(3),
	LOADING_END_TS_UTC TIMESTAMP_NTZ(3),
	LOADING_START_TS_LOCAL TIMESTAMP_NTZ(3),
	LOADING_END_TS_LOCAL TIMESTAMP_NTZ(3),
	LOADING_DURATION_MINS NUMBER(38,6),
	FULL_TRAVEL_START_TS_UTC TIMESTAMP_NTZ(3),
	FULL_TRAVEL_END_TS_UTC TIMESTAMP_NTZ(3),
	FULL_TRAVEL_START_TS_LOCAL TIMESTAMP_NTZ(3),
	FULL_TRAVEL_END_TS_LOCAL TIMESTAMP_NTZ(3),
	FULL_TRAVEL_DURATION_MINS NUMBER(38,6),
	FULL_TRAVEL_DISTANCE_FEET NUMBER(38,6),
	FULL_TRAVEL_DISTANCE_METERS NUMBER(38,6),
	DUMPING_START_TS_UTC TIMESTAMP_NTZ(3),
	DUMPING_END_TS_UTC TIMESTAMP_NTZ(3),
	DUMPING_START_TS_LOCAL TIMESTAMP_NTZ(3),
	DUMPING_END_TS_LOCAL TIMESTAMP_NTZ(3),
	DUMPING_DURATION_MINS NUMBER(38,6),
	CYCLE_DURATION_MINS NUMBER(38,6),
	DELTA_C_MINS NUMBER(38,6),
	FUEL_USED_IN_CYCLE_GALLONS NUMBER(38,6),
	TCU_PCT NUMBER(38,6),
	XCU_PCT NUMBER(38,6),
	INSOL_PCT NUMBER(38,6),
	SYSTEM_VERSION VARCHAR(50) COLLATE 'en-ci',
	DW_LOGICAL_DELETE_FLAG VARCHAR(1) COLLATE 'en-ci' DEFAULT 'N',
	DW_LOAD_TS TIMESTAMP_NTZ(0),
	DW_MODIFY_TS TIMESTAMP_NTZ(0)
)COMMENT='Incremental table for LH_HAUL_CYCLE - MERGE-driven upserts with 3-day incremental window'
;;



-- ============================================================================
-- SECTION 2: STORED PROCEDURE DDL (11 Procedures)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- PROCEDURE: BL_DW_BLAST_INCR_P
-- ----------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS TEST_API_REF.FUSE.BL_DW_BLAST_INCR_P(VARCHAR);

CREATE OR REPLACE PROCEDURE "BL_DW_BLAST_INCR_P"("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
/*****************************************************************************************
* PURPOSE   : Merge data from BL_DW_BLAST into BL_DW_BLAST_INCR
* SOURCE    : PROD_WG.DRILL_BLAST.BL_DW_BLAST
* TARGET    : SANDBOX_DATA_ENGINEER.CCARRILL2.BL_DW_BLAST_INCR
* BUSINESS KEY: ORIG_SRC_ID, SITE_CODE, ID
* INCREMENTAL COLUMN: DW_MODIFY_TS
* DATE: 2026-01-23 | AUTHOR: CARLOS CARRILLO
******************************************************************************************/

var sp_result="";
var sql_count_incr, sql_delete_incr, sql_merge, sql_delete;
var rs_count_incr, rs_delete_incr, rs_merge, rs_delete;
var rs_records_incr, rs_deleted_records_incr, rs_merged_records, rs_delete_records;

sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                  FROM TEST_API_REF.FUSE.bl_dw_blast_incr 
                  WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_delete_incr = `DELETE FROM TEST_API_REF.FUSE.bl_dw_blast_incr 
                   WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_merge = `MERGE INTO TEST_API_REF.FUSE.bl_dw_blast_incr tgt
USING (
    SELECT
        orig_src_id, site_code, id, name, status,
        firedtime, abandonedtime, abandonedcomment,
        suspendedtime, suspendedcomment, volume,
        holecount, shotfirername, refreshedtime, deleted,
        dw_file_ts_utc,
        ''N'' AS dw_logical_delete_flag,
        CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
        dw_modify_ts
    FROM prod_wg.drill_blast.bl_dw_blast
    WHERE dw_modify_ts >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_TIMESTAMP())
) AS src

ON tgt.orig_src_id = src.orig_src_id 
   AND tgt.site_code = src.site_code 
   AND tgt.id = src.id

WHEN MATCHED AND HASH(src.name, src.status, src.firedtime, src.volume, src.holecount, src.deleted)
              <> HASH(tgt.name, tgt.status, tgt.firedtime, tgt.volume, tgt.holecount, tgt.deleted)
THEN UPDATE SET
    tgt.name = src.name, tgt.status = src.status,
    tgt.firedtime = src.firedtime, tgt.abandonedtime = src.abandonedtime,
    tgt.abandonedcomment = src.abandonedcomment, tgt.suspendedtime = src.suspendedtime,
    tgt.suspendedcomment = src.suspendedcomment, tgt.volume = src.volume,
    tgt.holecount = src.holecount, tgt.shotfirername = src.shotfirername,
    tgt.refreshedtime = src.refreshedtime, tgt.deleted = src.deleted,
    tgt.dw_file_ts_utc = src.dw_file_ts_utc, tgt.dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ

WHEN NOT MATCHED THEN INSERT (
    orig_src_id, site_code, id, name, status, firedtime, abandonedtime,
    abandonedcomment, suspendedtime, suspendedcomment, volume, holecount,
    shotfirername, refreshedtime, deleted, dw_file_ts_utc,
    dw_logical_delete_flag, dw_load_ts, dw_modify_ts
) VALUES (
    src.orig_src_id, src.site_code, src.id, src.name, src.status, src.firedtime,
    src.abandonedtime, src.abandonedcomment, src.suspendedtime, src.suspendedcomment,
    src.volume, src.holecount, src.shotfirername, src.refreshedtime, src.deleted,
    src.dw_file_ts_utc, src.dw_logical_delete_flag, src.dw_load_ts, src.dw_modify_ts
);`;

sql_delete = `UPDATE TEST_API_REF.FUSE.bl_dw_blast_incr tgt
              SET dw_logical_delete_flag = ''Y'', dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
              WHERE tgt.dw_logical_delete_flag = ''N''
              AND NOT EXISTS (
                  SELECT 1 FROM prod_wg.drill_blast.bl_dw_blast src
                  WHERE src.orig_src_id = tgt.orig_src_id 
                    AND src.site_code = tgt.site_code 
                    AND src.id = tgt.id
              );`;

try {
    snowflake.execute({sqlText: "BEGIN WORK;"});
    rs_count_incr = snowflake.execute({sqlText: sql_count_incr});
    rs_count_incr.next();
    rs_records_incr = rs_count_incr.getColumnValue(''COUNT_CHECK_1'');

    if (rs_records_incr > 0) {
        rs_delete_incr = snowflake.execute({sqlText: sql_delete_incr});
        rs_deleted_records_incr = rs_delete_incr.getNumRowsAffected();
    } else {
        rs_deleted_records_incr = 0;
    }
    
    rs_merge = snowflake.execute({sqlText: sql_merge});
    rs_merged_records = rs_merge.getNumRowsAffected();
    
    rs_delete = snowflake.execute({sqlText: sql_delete});
    rs_delete_records = rs_delete.getNumRowsAffected();
    
    sp_result = "Deleted: " + rs_deleted_records_incr + ", Merged: " + rs_merged_records + ", Archived: " + rs_delete_records;
    snowflake.execute({sqlText: "COMMIT WORK;"});
    return sp_result;
}
catch (err) {
    snowflake.execute({sqlText: "ROLLBACK WORK;"});
    throw err;
}
';

-- ----------------------------------------------------------------------------
-- PROCEDURE: BL_DW_BLASTPROPERTYVALUE_INCR_P
-- ----------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS TEST_API_REF.FUSE.BL_DW_BLASTPROPERTYVALUE_INCR_P(VARCHAR);

CREATE OR REPLACE PROCEDURE "BL_DW_BLASTPROPERTYVALUE_INCR_P"("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var sp_result="";
var sql_count_incr, sql_delete_incr, sql_merge, sql_delete;
var rs_count_incr, rs_delete_incr, rs_merge, rs_delete;
var rs_records_incr, rs_deleted_records_incr, rs_merged_records, rs_delete_records;

sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                  FROM TEST_API_REF.FUSE.bl_dw_blastpropertyvalue_incr 
                  WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_delete_incr = `DELETE FROM TEST_API_REF.FUSE.bl_dw_blastpropertyvalue_incr 
                   WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_merge = `MERGE INTO TEST_API_REF.FUSE.bl_dw_blastpropertyvalue_incr tgt
USING (
    SELECT orig_src_id, site_code, blastid, refreshedtime, deleted,
           parameter, planneddate, shottype, shotgoal, dw_file_ts_utc,
           ''N'' AS dw_logical_delete_flag,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts, dw_modify_ts
    FROM prod_wg.drill_blast.bl_dw_blastpropertyvalue
    WHERE dw_modify_ts >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_TIMESTAMP())
) AS src
ON tgt.orig_src_id = src.orig_src_id AND tgt.site_code = src.site_code AND tgt.blastid = src.blastid
WHEN MATCHED AND HASH(src.parameter, src.planneddate, src.shottype, src.shotgoal, src.deleted)
              <> HASH(tgt.parameter, tgt.planneddate, tgt.shottype, tgt.shotgoal, tgt.deleted)
THEN UPDATE SET
    tgt.refreshedtime = src.refreshedtime, tgt.deleted = src.deleted,
    tgt.parameter = src.parameter, tgt.planneddate = src.planneddate,
    tgt.shottype = src.shottype, tgt.shotgoal = src.shotgoal,
    tgt.dw_file_ts_utc = src.dw_file_ts_utc, tgt.dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
WHEN NOT MATCHED THEN INSERT (
    orig_src_id, site_code, blastid, refreshedtime, deleted, parameter,
    planneddate, shottype, shotgoal, dw_file_ts_utc, dw_logical_delete_flag, dw_load_ts, dw_modify_ts
) VALUES (
    src.orig_src_id, src.site_code, src.blastid, src.refreshedtime, src.deleted, src.parameter,
    src.planneddate, src.shottype, src.shotgoal, src.dw_file_ts_utc, src.dw_logical_delete_flag, src.dw_load_ts, src.dw_modify_ts
);`;

sql_delete = `UPDATE TEST_API_REF.FUSE.bl_dw_blastpropertyvalue_incr tgt
              SET dw_logical_delete_flag = ''Y'', dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
              WHERE tgt.dw_logical_delete_flag = ''N''
              AND NOT EXISTS (SELECT 1 FROM prod_wg.drill_blast.bl_dw_blastpropertyvalue src
                  WHERE src.orig_src_id = tgt.orig_src_id AND src.site_code = tgt.site_code AND src.blastid = tgt.blastid);`;

try {
    snowflake.execute({sqlText: "BEGIN WORK;"});
    rs_count_incr = snowflake.execute({sqlText: sql_count_incr});
    rs_count_incr.next();
    rs_records_incr = rs_count_incr.getColumnValue(''COUNT_CHECK_1'');
    rs_deleted_records_incr = rs_records_incr > 0 ? snowflake.execute({sqlText: sql_delete_incr}).getNumRowsAffected() : 0;
    rs_merge = snowflake.execute({sqlText: sql_merge});
    rs_merged_records = rs_merge.getNumRowsAffected();
    rs_delete = snowflake.execute({sqlText: sql_delete});
    rs_delete_records = rs_delete.getNumRowsAffected();
    sp_result = "Deleted: " + rs_deleted_records_incr + ", Merged: " + rs_merged_records + ", Archived: " + rs_delete_records;
    snowflake.execute({sqlText: "COMMIT WORK;"});
    return sp_result;
} catch (err) { snowflake.execute({sqlText: "ROLLBACK WORK;"}); throw err; }
';

-- ----------------------------------------------------------------------------
-- PROCEDURE: BL_DW_HOLE_INCR_P
-- ----------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS TEST_API_REF.FUSE.BL_DW_HOLE_INCR_P(VARCHAR);

CREATE OR REPLACE PROCEDURE "BL_DW_HOLE_INCR_P"("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var sp_result="";
var sql_count_incr, sql_delete_incr, sql_merge, sql_delete;

sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                  FROM TEST_API_REF.FUSE.bl_dw_hole_incr 
                  WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_delete_incr = `DELETE FROM TEST_API_REF.FUSE.bl_dw_hole_incr 
                   WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_merge = `MERGE INTO TEST_API_REF.FUSE.bl_dw_hole_incr tgt
USING (
    SELECT orig_src_id, site_code, id, name, modified_name, blastname, modified_blastname, 
           blastid, "ROW" AS hole_row, echelon, status, lastknowndepth, lastknownwater, 
           lastknownwetsides, lastknowntemperature, lastknowntemperaturetime,
           previoustemperature, previoustemperaturetime, temperaturerateofchange,
           designtime, drilledtime, lastdipdepth, lastdippedtime,
           lastbackfillingdipdepth, lastbackfillingdiptime, lastchargingdipdepth, lastchargingdiptime,
           chargedtime, firedtime, abandonedtime, abandonedcomment, misfire, misfirecomment,
           redrillofholeid, redrillofholename, isadhoc,
           designcollarx, designcollary, designcollarz, designangle, designbearing, designdepth,
           designdiameter, designburden, designspacing, actualcollarx, actualcollary, actualcollarz,
           targetchargedepth, plannedprimercount, loadedprimercount, loadedexplosivedeckcount,
           dippedoutsidechargedepthtolerance, chargedoutsidemasstolerance, drilledoutsidecollartolerance,
           topmoststemmingdeckloaded, stemmedoutsidelengthtolerance,
           explosivemassdesigned, explosivemassloaded, explosivemassreconciled,
           stemminglengthdesigned, stemminglengthloaded, stemminglengthreconciled,
           designtieupcount, actualtieupcount, designdrillcost, chargestandoff, chargestandoffdirection,
           refreshedtime, deleted, dw_file_ts_utc,
           ''N'' AS dw_logical_delete_flag,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts_new,
           dw_modify_ts
    FROM prod_wg.drill_blast.bl_dw_hole
    WHERE dw_modify_ts >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_TIMESTAMP())
) AS src
ON tgt.orig_src_id = src.orig_src_id AND tgt.site_code = src.site_code AND tgt.id = src.id
WHEN MATCHED AND HASH(src.name, src.status, src.blastid, src.lastknowndepth, src.designdepth, src.deleted)
              <> HASH(tgt.name, tgt.status, tgt.blastid, tgt.lastknowndepth, tgt.designdepth, tgt.deleted)
THEN UPDATE SET
    tgt.name = src.name, tgt.modified_name = src.modified_name,
    tgt.blastname = src.blastname, tgt.modified_blastname = src.modified_blastname,
    tgt.blastid = src.blastid, tgt."ROW" = src.hole_row, tgt.echelon = src.echelon, tgt.status = src.status,
    tgt.lastknowndepth = src.lastknowndepth, tgt.deleted = src.deleted,
    tgt.dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
WHEN NOT MATCHED THEN INSERT (
    orig_src_id, site_code, id, name, modified_name, blastname, modified_blastname, blastid, "ROW", echelon, status,
    lastknowndepth, deleted, dw_logical_delete_flag, dw_load_ts, dw_modify_ts
) VALUES (
    src.orig_src_id, src.site_code, src.id, src.name, src.modified_name, src.blastname, src.modified_blastname,
    src.blastid, src.hole_row, src.echelon, src.status, src.lastknowndepth, src.deleted, 
    src.dw_logical_delete_flag, src.dw_load_ts_new, src.dw_modify_ts
);`;

sql_delete = `UPDATE TEST_API_REF.FUSE.bl_dw_hole_incr tgt
              SET dw_logical_delete_flag = ''Y'', dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
              WHERE tgt.dw_logical_delete_flag = ''N''
              AND NOT EXISTS (SELECT 1 FROM prod_wg.drill_blast.bl_dw_hole src
                  WHERE src.orig_src_id = tgt.orig_src_id AND src.site_code = tgt.site_code AND src.id = tgt.id);`;

try {
    snowflake.execute({sqlText: "BEGIN WORK;"});
    var rs_count_incr = snowflake.execute({sqlText: sql_count_incr});
    rs_count_incr.next();
    var rs_records_incr = rs_count_incr.getColumnValue(''COUNT_CHECK_1'');
    var rs_deleted_records_incr = rs_records_incr > 0 ? snowflake.execute({sqlText: sql_delete_incr}).getNumRowsAffected() : 0;
    var rs_merge = snowflake.execute({sqlText: sql_merge});
    var rs_merged_records = rs_merge.getNumRowsAffected();
    var rs_delete = snowflake.execute({sqlText: sql_delete});
    var rs_delete_records = rs_delete.getNumRowsAffected();
    sp_result = "Deleted: " + rs_deleted_records_incr + ", Merged: " + rs_merged_records + ", Archived: " + rs_delete_records;
    snowflake.execute({sqlText: "COMMIT WORK;"});
    return sp_result;
} catch (err) { snowflake.execute({sqlText: "ROLLBACK WORK;"}); throw err; }
';

-- ----------------------------------------------------------------------------
-- PROCEDURE: BLAST_PLAN_INCR_P
-- ----------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS TEST_API_REF.FUSE.BLAST_PLAN_INCR_P(VARCHAR);

CREATE OR REPLACE PROCEDURE "BLAST_PLAN_INCR_P"("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var sp_result="";
var daysBack = NUMBER_OF_DAYS || 3;

var sql_merge = `MERGE INTO TEST_API_REF.FUSE.blast_plan_incr tgt
USING (
    SELECT BLAST_PLAN_SK, ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
           DW_MODIFY_TS,
           ''N'' AS dw_logical_delete_flag,
           HASH(BLAST_PLAN_SK, ORIG_SRC_ID, SITE_CODE) AS dw_row_hash
    FROM PROD_WG.DRILL_BLAST.BLAST_PLAN
    WHERE DW_MODIFY_TS >= DATEADD(day, -` + daysBack + `, CURRENT_TIMESTAMP())
) AS src
ON tgt.BLAST_PLAN_SK = src.BLAST_PLAN_SK
WHEN MATCHED THEN UPDATE SET
    tgt.ORIG_SRC_ID = src.ORIG_SRC_ID, tgt.SITE_CODE = src.SITE_CODE, tgt.BENCH = src.BENCH,
    tgt.PUSHBACK = src.PUSHBACK, tgt.PATTERN_NAME = src.PATTERN_NAME, tgt.BLAST_NAME = src.BLAST_NAME,
    tgt.DW_MODIFY_TS = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ, tgt.DW_ROW_HASH = src.dw_row_hash
WHEN NOT MATCHED THEN INSERT (BLAST_PLAN_SK, ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME, 
    DW_LOAD_TS, DW_MODIFY_TS, DW_LOGICAL_DELETE_FLAG, DW_ROW_HASH)
VALUES (src.BLAST_PLAN_SK, src.ORIG_SRC_ID, src.SITE_CODE, src.BENCH, src.PUSHBACK, src.PATTERN_NAME, src.BLAST_NAME,
    src.dw_load_ts, CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ, src.dw_logical_delete_flag, src.dw_row_hash);`;

try {
    var rs_merge = snowflake.execute({sqlText: sql_merge});
    var rs_merged_records = rs_merge.getNumRowsAffected();
    sp_result = "Deleted: 0, Merged: " + rs_merged_records + ", Archived: 0";
    return sp_result;
} catch (err) { throw err; }
';

-- ----------------------------------------------------------------------------
-- PROCEDURE: BLAST_PLAN_EXECUTION_INCR_P
-- ----------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS TEST_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR_P(VARCHAR);

CREATE OR REPLACE PROCEDURE "BLAST_PLAN_EXECUTION_INCR_P"("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var sp_result="";
var sql_count_incr, sql_delete_incr, sql_merge, sql_delete;

sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                  FROM TEST_API_REF.FUSE.blast_plan_execution_incr 
                  WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_delete_incr = `DELETE FROM TEST_API_REF.FUSE.blast_plan_execution_incr 
                   WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

sql_merge = `MERGE INTO TEST_API_REF.FUSE.blast_plan_execution_incr tgt
USING (
    SELECT 
        ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME, DRILLED_HOLE_ID,
        DRILLED_HOLE_NAME, DRILL_CYCLE_SK, BLAST_PLAN_SK, SHIFT_ID, BLAST_ID,
        SHOT_DATE_UTC, SHOT_DATE_LOCAL, BLAST_TYPE, BLAST_ENGINEER_NAME, LOADING_TRUCK_OPERATOR_NAME,
        HOLE_LOADED_TS_UTC, HOLE_LOADED_TS_LOCAL,
        HOLE_LAST_KNOWN_DEPTH_METERS, HOLE_LAST_KNOWN_DEPTH_FEET,
        HOLE_TAPED_DEPTH_METERS, HOLE_TAPED_DEPTH_FEET, HOLE_PLUGGED_FLAG,
        EXPLOSIVE_PRODUCT_BOTTOM, EXPLOSIVE_PRODUCT_TOP,
        EXPLOSIVE_PRODUCT_USED_BOTTOM_KILOGRAMS, EXPLOSIVE_PRODUCT_USED_BOTTOM_POUNDS,
        EXPLOSIVE_PRODUCT_USED_TOP_KILOGRAMS, EXPLOSIVE_PRODUCT_USED_TOP_POUNDS,
        EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_METERS, EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_FEET,
        EXPLOSIVE_PRODUCT_LENGTH_TOP_METERS, EXPLOSIVE_PRODUCT_LENGTH_TOP_FEET,
        STEMMING_LENGTH_TOTAL_METERS, STEMMING_LENGTH_TOTAL_FEET,
        STEMMING_LENGTH_BOTTOM_METERS, STEMMING_LENGTH_BOTTOM_FEET,
        STEMMING_LENGTH_TOP_METERS, STEMMING_LENGTH_TOP_FEET,
        BURDEN_METERS, BURDEN_FEET, SPACING_METERS, SPACING_FEET,
        TONS_PER_HOLE, KCALS_PER_TON, POWDER_FACTOR, MEGAJOULES_PER_TON, CONFINEMENT_FACTOR, PRIMER_COUNT,
        HOLE_TEMPERATURE_CELSIUS, HOLE_TEMPERATURE_FAHRENHEIT,
        PRODUCT_BOTTOM_COMMENTS, PRODUCT_TOP_COMMENTS, STEMMING_BOTTOM_COMMENT, STEMMING_TOP_COMMENT,
        WATER_DEPTH_METERS, WATER_DEPTH_FEET, MISFIRE_FLAG,
        DW_LOAD_TS,
        DW_MODIFY_TS,
        ''N'' AS DW_LOGICAL_DELETE_FLAG,
        CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts_new
    FROM prod_wg.drill_blast.blast_plan_execution
    WHERE DW_MODIFY_TS >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_TIMESTAMP())
    -- Fix: Deduplicate source to prevent MERGE duplicate row error
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME, DRILLED_HOLE_ID
        ORDER BY DW_MODIFY_TS DESC NULLS LAST
    ) = 1
) AS src
ON tgt.ORIG_SRC_ID = src.ORIG_SRC_ID 
   AND tgt.SITE_CODE = src.SITE_CODE 
   AND tgt.BENCH = src.BENCH 
   AND COALESCE(tgt.PUSHBACK, '''') = COALESCE(src.PUSHBACK, '''')
   AND COALESCE(tgt.PATTERN_NAME, '''') = COALESCE(src.PATTERN_NAME, '''')
   AND tgt.BLAST_NAME = src.BLAST_NAME 
   AND tgt.DRILLED_HOLE_ID = src.DRILLED_HOLE_ID
WHEN MATCHED AND HASH(src.DRILLED_HOLE_NAME, src.BLAST_TYPE, src.BLAST_ENGINEER_NAME, 
                      src.TONS_PER_HOLE, src.POWDER_FACTOR, src.MISFIRE_FLAG)
              <> HASH(tgt.DRILLED_HOLE_NAME, tgt.BLAST_TYPE, tgt.BLAST_ENGINEER_NAME, 
                      tgt.TONS_PER_HOLE, tgt.POWDER_FACTOR, tgt.MISFIRE_FLAG)
THEN UPDATE SET
    tgt.DRILLED_HOLE_NAME = src.DRILLED_HOLE_NAME,
    tgt.DRILL_CYCLE_SK = src.DRILL_CYCLE_SK,
    tgt.BLAST_PLAN_SK = src.BLAST_PLAN_SK,
    tgt.SHIFT_ID = src.SHIFT_ID,
    tgt.BLAST_ID = src.BLAST_ID,
    tgt.SHOT_DATE_UTC = src.SHOT_DATE_UTC,
    tgt.SHOT_DATE_LOCAL = src.SHOT_DATE_LOCAL,
    tgt.BLAST_TYPE = src.BLAST_TYPE,
    tgt.BLAST_ENGINEER_NAME = src.BLAST_ENGINEER_NAME,
    tgt.LOADING_TRUCK_OPERATOR_NAME = src.LOADING_TRUCK_OPERATOR_NAME,
    tgt.HOLE_LOADED_TS_UTC = src.HOLE_LOADED_TS_UTC,
    tgt.HOLE_LOADED_TS_LOCAL = src.HOLE_LOADED_TS_LOCAL,
    tgt.HOLE_LAST_KNOWN_DEPTH_METERS = src.HOLE_LAST_KNOWN_DEPTH_METERS,
    tgt.HOLE_LAST_KNOWN_DEPTH_FEET = src.HOLE_LAST_KNOWN_DEPTH_FEET,
    tgt.HOLE_TAPED_DEPTH_METERS = src.HOLE_TAPED_DEPTH_METERS,
    tgt.HOLE_TAPED_DEPTH_FEET = src.HOLE_TAPED_DEPTH_FEET,
    tgt.HOLE_PLUGGED_FLAG = src.HOLE_PLUGGED_FLAG,
    tgt.EXPLOSIVE_PRODUCT_BOTTOM = src.EXPLOSIVE_PRODUCT_BOTTOM,
    tgt.EXPLOSIVE_PRODUCT_TOP = src.EXPLOSIVE_PRODUCT_TOP,
    tgt.EXPLOSIVE_PRODUCT_USED_BOTTOM_KILOGRAMS = src.EXPLOSIVE_PRODUCT_USED_BOTTOM_KILOGRAMS,
    tgt.EXPLOSIVE_PRODUCT_USED_BOTTOM_POUNDS = src.EXPLOSIVE_PRODUCT_USED_BOTTOM_POUNDS,
    tgt.EXPLOSIVE_PRODUCT_USED_TOP_KILOGRAMS = src.EXPLOSIVE_PRODUCT_USED_TOP_KILOGRAMS,
    tgt.EXPLOSIVE_PRODUCT_USED_TOP_POUNDS = src.EXPLOSIVE_PRODUCT_USED_TOP_POUNDS,
    tgt.EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_METERS = src.EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_METERS,
    tgt.EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_FEET = src.EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_FEET,
    tgt.EXPLOSIVE_PRODUCT_LENGTH_TOP_METERS = src.EXPLOSIVE_PRODUCT_LENGTH_TOP_METERS,
    tgt.EXPLOSIVE_PRODUCT_LENGTH_TOP_FEET = src.EXPLOSIVE_PRODUCT_LENGTH_TOP_FEET,
    tgt.STEMMING_LENGTH_TOTAL_METERS = src.STEMMING_LENGTH_TOTAL_METERS,
    tgt.STEMMING_LENGTH_TOTAL_FEET = src.STEMMING_LENGTH_TOTAL_FEET,
    tgt.STEMMING_LENGTH_BOTTOM_METERS = src.STEMMING_LENGTH_BOTTOM_METERS,
    tgt.STEMMING_LENGTH_BOTTOM_FEET = src.STEMMING_LENGTH_BOTTOM_FEET,
    tgt.STEMMING_LENGTH_TOP_METERS = src.STEMMING_LENGTH_TOP_METERS,
    tgt.STEMMING_LENGTH_TOP_FEET = src.STEMMING_LENGTH_TOP_FEET,
    tgt.BURDEN_METERS = src.BURDEN_METERS,
    tgt.BURDEN_FEET = src.BURDEN_FEET,
    tgt.SPACING_METERS = src.SPACING_METERS,
    tgt.SPACING_FEET = src.SPACING_FEET,
    tgt.TONS_PER_HOLE = src.TONS_PER_HOLE,
    tgt.KCALS_PER_TON = src.KCALS_PER_TON,
    tgt.POWDER_FACTOR = src.POWDER_FACTOR,
    tgt.MEGAJOULES_PER_TON = src.MEGAJOULES_PER_TON,
    tgt.CONFINEMENT_FACTOR = src.CONFINEMENT_FACTOR,
    tgt.PRIMER_COUNT = src.PRIMER_COUNT,
    tgt.HOLE_TEMPERATURE_CELSIUS = src.HOLE_TEMPERATURE_CELSIUS,
    tgt.HOLE_TEMPERATURE_FAHRENHEIT = src.HOLE_TEMPERATURE_FAHRENHEIT,
    tgt.PRODUCT_BOTTOM_COMMENTS = src.PRODUCT_BOTTOM_COMMENTS,
    tgt.PRODUCT_TOP_COMMENTS = src.PRODUCT_TOP_COMMENTS,
    tgt.STEMMING_BOTTOM_COMMENT = src.STEMMING_BOTTOM_COMMENT,
    tgt.STEMMING_TOP_COMMENT = src.STEMMING_TOP_COMMENT,
    tgt.WATER_DEPTH_METERS = src.WATER_DEPTH_METERS,
    tgt.WATER_DEPTH_FEET = src.WATER_DEPTH_FEET,
    tgt.MISFIRE_FLAG = src.MISFIRE_FLAG,
    tgt.DW_LOAD_TS = src.DW_LOAD_TS,
    tgt.DW_MODIFY_TS = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
WHEN NOT MATCHED THEN INSERT (
    ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME, DRILLED_HOLE_ID,
    DRILLED_HOLE_NAME, DRILL_CYCLE_SK, BLAST_PLAN_SK, SHIFT_ID, BLAST_ID,
    SHOT_DATE_UTC, SHOT_DATE_LOCAL, BLAST_TYPE, BLAST_ENGINEER_NAME, LOADING_TRUCK_OPERATOR_NAME,
    HOLE_LOADED_TS_UTC, HOLE_LOADED_TS_LOCAL,
    HOLE_LAST_KNOWN_DEPTH_METERS, HOLE_LAST_KNOWN_DEPTH_FEET,
    HOLE_TAPED_DEPTH_METERS, HOLE_TAPED_DEPTH_FEET, HOLE_PLUGGED_FLAG,
    EXPLOSIVE_PRODUCT_BOTTOM, EXPLOSIVE_PRODUCT_TOP,
    EXPLOSIVE_PRODUCT_USED_BOTTOM_KILOGRAMS, EXPLOSIVE_PRODUCT_USED_BOTTOM_POUNDS,
    EXPLOSIVE_PRODUCT_USED_TOP_KILOGRAMS, EXPLOSIVE_PRODUCT_USED_TOP_POUNDS,
    EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_METERS, EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_FEET,
    EXPLOSIVE_PRODUCT_LENGTH_TOP_METERS, EXPLOSIVE_PRODUCT_LENGTH_TOP_FEET,
    STEMMING_LENGTH_TOTAL_METERS, STEMMING_LENGTH_TOTAL_FEET,
    STEMMING_LENGTH_BOTTOM_METERS, STEMMING_LENGTH_BOTTOM_FEET,
    STEMMING_LENGTH_TOP_METERS, STEMMING_LENGTH_TOP_FEET,
    BURDEN_METERS, BURDEN_FEET, SPACING_METERS, SPACING_FEET,
    TONS_PER_HOLE, KCALS_PER_TON, POWDER_FACTOR, MEGAJOULES_PER_TON, CONFINEMENT_FACTOR, PRIMER_COUNT,
    HOLE_TEMPERATURE_CELSIUS, HOLE_TEMPERATURE_FAHRENHEIT,
    PRODUCT_BOTTOM_COMMENTS, PRODUCT_TOP_COMMENTS, STEMMING_BOTTOM_COMMENT, STEMMING_TOP_COMMENT,
    WATER_DEPTH_METERS, WATER_DEPTH_FEET, MISFIRE_FLAG,
    DW_LOAD_TS, DW_MODIFY_TS, DW_LOGICAL_DELETE_FLAG
) VALUES (
    src.ORIG_SRC_ID, src.SITE_CODE, src.BENCH, src.PUSHBACK, src.PATTERN_NAME, src.BLAST_NAME, src.DRILLED_HOLE_ID,
    src.DRILLED_HOLE_NAME, src.DRILL_CYCLE_SK, src.BLAST_PLAN_SK, src.SHIFT_ID, src.BLAST_ID,
    src.SHOT_DATE_UTC, src.SHOT_DATE_LOCAL, src.BLAST_TYPE, src.BLAST_ENGINEER_NAME, src.LOADING_TRUCK_OPERATOR_NAME,
    src.HOLE_LOADED_TS_UTC, src.HOLE_LOADED_TS_LOCAL,
    src.HOLE_LAST_KNOWN_DEPTH_METERS, src.HOLE_LAST_KNOWN_DEPTH_FEET,
    src.HOLE_TAPED_DEPTH_METERS, src.HOLE_TAPED_DEPTH_FEET, src.HOLE_PLUGGED_FLAG,
    src.EXPLOSIVE_PRODUCT_BOTTOM, src.EXPLOSIVE_PRODUCT_TOP,
    src.EXPLOSIVE_PRODUCT_USED_BOTTOM_KILOGRAMS, src.EXPLOSIVE_PRODUCT_USED_BOTTOM_POUNDS,
    src.EXPLOSIVE_PRODUCT_USED_TOP_KILOGRAMS, src.EXPLOSIVE_PRODUCT_USED_TOP_POUNDS,
    src.EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_METERS, src.EXPLOSIVE_PRODUCT_LENGTH_BOTTOM_FEET,
    src.EXPLOSIVE_PRODUCT_LENGTH_TOP_METERS, src.EXPLOSIVE_PRODUCT_LENGTH_TOP_FEET,
    src.STEMMING_LENGTH_TOTAL_METERS, src.STEMMING_LENGTH_TOTAL_FEET,
    src.STEMMING_LENGTH_BOTTOM_METERS, src.STEMMING_LENGTH_BOTTOM_FEET,
    src.STEMMING_LENGTH_TOP_METERS, src.STEMMING_LENGTH_TOP_FEET,
    src.BURDEN_METERS, src.BURDEN_FEET, src.SPACING_METERS, src.SPACING_FEET,
    src.TONS_PER_HOLE, src.KCALS_PER_TON, src.POWDER_FACTOR, src.MEGAJOULES_PER_TON, src.CONFINEMENT_FACTOR, src.PRIMER_COUNT,
    src.HOLE_TEMPERATURE_CELSIUS, src.HOLE_TEMPERATURE_FAHRENHEIT,
    src.PRODUCT_BOTTOM_COMMENTS, src.PRODUCT_TOP_COMMENTS, src.STEMMING_BOTTOM_COMMENT, src.STEMMING_TOP_COMMENT,
    src.WATER_DEPTH_METERS, src.WATER_DEPTH_FEET, src.MISFIRE_FLAG,
    src.dw_load_ts_new, src.dw_load_ts_new, src.DW_LOGICAL_DELETE_FLAG
)`;

sql_delete = `UPDATE TEST_API_REF.FUSE.blast_plan_execution_incr tgt
SET DW_LOGICAL_DELETE_FLAG = ''Y'', DW_MODIFY_TS = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
WHERE NOT EXISTS (
    SELECT 1 FROM prod_wg.drill_blast.blast_plan_execution src
    WHERE tgt.ORIG_SRC_ID = src.ORIG_SRC_ID 
      AND tgt.SITE_CODE = src.SITE_CODE 
      AND tgt.BENCH = src.BENCH 
      AND COALESCE(tgt.PUSHBACK, '''') = COALESCE(src.PUSHBACK, '''')
      AND COALESCE(tgt.PATTERN_NAME, '''') = COALESCE(src.PATTERN_NAME, '''')
      AND tgt.BLAST_NAME = src.BLAST_NAME 
      AND tgt.DRILLED_HOLE_ID = src.DRILLED_HOLE_ID
)
AND tgt.DW_LOGICAL_DELETE_FLAG = ''N''`;

try {
    // Count old records
    var stmt1 = snowflake.createStatement({sqlText: sql_count_incr});
    var resultSet1 = stmt1.execute();
    resultSet1.next();
    var old_count = resultSet1.getColumnValue(1);
    
    // Delete old records
    var stmt2 = snowflake.createStatement({sqlText: sql_delete_incr});
    stmt2.execute();
    var deleted_count = stmt2.getNumRowsAffected();
    
    // Merge new/updated records
    var stmt3 = snowflake.createStatement({sqlText: sql_merge});
    stmt3.execute();
    var merged_count = stmt3.getNumRowsAffected();
    
    // Soft delete missing records
    var stmt4 = snowflake.createStatement({sqlText: sql_delete});
    stmt4.execute();
    var soft_deleted_count = stmt4.getNumRowsAffected();
    
    sp_result = "SUCCESS: Deleted " + deleted_count + " old records, Merged " + merged_count + " records, Soft deleted " + soft_deleted_count + " records";
} catch(err) {
    sp_result = "ERROR: " + err.message;
}

return sp_result;
';

-- ----------------------------------------------------------------------------
-- PROCEDURE: DRILL_CYCLE_INCR_P
-- ----------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS TEST_API_REF.FUSE.DRILL_CYCLE_INCR_P(VARCHAR);

CREATE OR REPLACE PROCEDURE "DRILL_CYCLE_INCR_P"("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var sp_result="";
var daysBack = NUMBER_OF_DAYS || 3;

var sql_merge = `MERGE INTO TEST_API_REF.FUSE.drill_cycle_incr tgt
USING (
    SELECT DRILL_CYCLE_SK, ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
           DW_MODIFY_TS,
           ''N'' AS dw_logical_delete_flag,
           HASH(DRILL_CYCLE_SK, ORIG_SRC_ID, SITE_CODE) AS dw_row_hash
    FROM PROD_WG.DRILL_BLAST.DRILL_CYCLE
    WHERE DW_MODIFY_TS >= DATEADD(day, -` + daysBack + `, CURRENT_TIMESTAMP())
) AS src
ON tgt.DRILL_CYCLE_SK = src.DRILL_CYCLE_SK
WHEN MATCHED THEN UPDATE SET
    tgt.ORIG_SRC_ID = src.ORIG_SRC_ID, tgt.SITE_CODE = src.SITE_CODE,
    tgt.BENCH = src.BENCH, tgt.PUSHBACK = src.PUSHBACK, tgt.PATTERN_NAME = src.PATTERN_NAME,
    tgt.DW_MODIFY_TS = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ, tgt.DW_ROW_HASH = src.dw_row_hash
WHEN NOT MATCHED THEN INSERT (DRILL_CYCLE_SK, ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME,
    DW_LOAD_TS, DW_MODIFY_TS, DW_LOGICAL_DELETE_FLAG, DW_ROW_HASH)
VALUES (src.DRILL_CYCLE_SK, src.ORIG_SRC_ID, src.SITE_CODE, src.BENCH, src.PUSHBACK, src.PATTERN_NAME,
    src.dw_load_ts, CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ, src.dw_logical_delete_flag, src.dw_row_hash);`;

try {
    var rs_merge = snowflake.execute({sqlText: sql_merge});
    var rs_merged_records = rs_merge.getNumRowsAffected();
    sp_result = "Deleted: 0, Merged: " + rs_merged_records + ", Archived: 0";
    return sp_result;
} catch (err) { throw err; }
';

-- ----------------------------------------------------------------------------
-- PROCEDURE: DRILL_PLAN_INCR_P
-- ----------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS TEST_API_REF.FUSE.DRILL_PLAN_INCR_P(VARCHAR);

CREATE OR REPLACE PROCEDURE "DRILL_PLAN_INCR_P"("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var sp_result="";
var daysBack = NUMBER_OF_DAYS || 3;

var sql_merge = `MERGE INTO TEST_API_REF.FUSE.drill_plan_incr tgt
USING (
    SELECT DRILL_PLAN_SK, ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
           DW_MODIFY_TS,
           ''N'' AS dw_logical_delete_flag,
           HASH(DRILL_PLAN_SK, ORIG_SRC_ID, SITE_CODE) AS dw_row_hash
    FROM PROD_WG.DRILL_BLAST.DRILL_PLAN
    WHERE DW_MODIFY_TS >= DATEADD(day, -` + daysBack + `, CURRENT_TIMESTAMP())
) AS src
ON tgt.DRILL_PLAN_SK = src.DRILL_PLAN_SK
WHEN MATCHED THEN UPDATE SET
    tgt.ORIG_SRC_ID = src.ORIG_SRC_ID, tgt.SITE_CODE = src.SITE_CODE,
    tgt.BENCH = src.BENCH, tgt.PUSHBACK = src.PUSHBACK, tgt.PATTERN_NAME = src.PATTERN_NAME,
    tgt.DW_MODIFY_TS = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ, tgt.DW_ROW_HASH = src.dw_row_hash
WHEN NOT MATCHED THEN INSERT (DRILL_PLAN_SK, ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME,
    DW_LOAD_TS, DW_MODIFY_TS, DW_LOGICAL_DELETE_FLAG, DW_ROW_HASH)
VALUES (src.DRILL_PLAN_SK, src.ORIG_SRC_ID, src.SITE_CODE, src.BENCH, src.PUSHBACK, src.PATTERN_NAME,
    src.dw_load_ts, CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ, src.dw_logical_delete_flag, src.dw_row_hash);`;

try {
    var rs_merge = snowflake.execute({sqlText: sql_merge});
    var rs_merged_records = rs_merge.getNumRowsAffected();
    sp_result = "Deleted: 0, Merged: " + rs_merged_records + ", Archived: 0";
    return sp_result;
} catch (err) { throw err; }
';

-- ----------------------------------------------------------------------------
-- PROCEDURE: DRILLBLAST_EQUIPMENT_INCR_P
-- ----------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS TEST_API_REF.FUSE.DRILLBLAST_EQUIPMENT_INCR_P(VARCHAR);

CREATE OR REPLACE PROCEDURE "DRILLBLAST_EQUIPMENT_INCR_P"("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var sp_result="";

var sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                      FROM TEST_API_REF.FUSE.drillblast_equipment_incr 
                      WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

var sql_delete_incr = `DELETE FROM TEST_API_REF.FUSE.drillblast_equipment_incr 
                       WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

var sql_merge = `MERGE INTO TEST_API_REF.FUSE.drillblast_equipment_incr tgt
USING (
    SELECT orig_src_id, site_code, drill_id, equip_name, equip_model,
           serial_number, equip_category, mem_equip_id, equip_unit_code,
           sap_equip_no, system_version,
           ''N'' AS dw_logical_delete_flag,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
           dw_modify_ts
    FROM prod_wg.drill_blast.drillblast_equipment
    WHERE dw_modify_ts::date >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE)
) AS src
ON tgt.orig_src_id = src.orig_src_id AND tgt.site_code = src.site_code AND tgt.drill_id = src.drill_id
WHEN MATCHED AND HASH(src.equip_name, src.equip_model, src.serial_number, src.equip_category, src.system_version)
              <> HASH(tgt.equip_name, tgt.equip_model, tgt.serial_number, tgt.equip_category, tgt.system_version)
THEN UPDATE SET
    tgt.equip_name = src.equip_name, tgt.equip_model = src.equip_model,
    tgt.serial_number = src.serial_number, tgt.equip_category = src.equip_category,
    tgt.mem_equip_id = src.mem_equip_id, tgt.equip_unit_code = src.equip_unit_code,
    tgt.sap_equip_no = src.sap_equip_no, tgt.system_version = src.system_version,
    tgt.dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
WHEN NOT MATCHED THEN INSERT (
    orig_src_id, site_code, drill_id, equip_name, equip_model, serial_number,
    equip_category, mem_equip_id, equip_unit_code, sap_equip_no, system_version,
    dw_logical_delete_flag, dw_load_ts, dw_modify_ts
) VALUES (
    src.orig_src_id, src.site_code, src.drill_id, src.equip_name, src.equip_model,
    src.serial_number, src.equip_category, src.mem_equip_id, src.equip_unit_code,
    src.sap_equip_no, src.system_version, src.dw_logical_delete_flag, src.dw_load_ts, src.dw_modify_ts
);`;

var sql_delete = `UPDATE TEST_API_REF.FUSE.drillblast_equipment_incr tgt
                  SET dw_logical_delete_flag = ''Y'', dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
                  WHERE tgt.dw_logical_delete_flag = ''N''
                  AND NOT EXISTS (SELECT 1 FROM prod_wg.drill_blast.drillblast_equipment src
                      WHERE src.orig_src_id = tgt.orig_src_id AND src.site_code = tgt.site_code AND src.drill_id = tgt.drill_id);`;

try {
    snowflake.execute({sqlText: "BEGIN WORK;"});
    var rs_count_incr = snowflake.execute({sqlText: sql_count_incr});
    rs_count_incr.next();
    var rs_records_incr = rs_count_incr.getColumnValue(''COUNT_CHECK_1'');
    var rs_deleted_records_incr = rs_records_incr > 0 ? snowflake.execute({sqlText: sql_delete_incr}).getNumRowsAffected() : 0;
    var rs_merge = snowflake.execute({sqlText: sql_merge});
    var rs_merged_records = rs_merge.getNumRowsAffected();
    var rs_delete = snowflake.execute({sqlText: sql_delete});
    var rs_delete_records = rs_delete.getNumRowsAffected();
    sp_result = "Deleted: " + rs_deleted_records_incr + ", Merged: " + rs_merged_records + ", Archived: " + rs_delete_records;
    snowflake.execute({sqlText: "COMMIT WORK;"});
    return sp_result;
} catch (err) { snowflake.execute({sqlText: "ROLLBACK WORK;"}); throw err; }
';

-- ----------------------------------------------------------------------------
-- PROCEDURE: DRILLBLAST_OPERATOR_INCR_P
-- ----------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS TEST_API_REF.FUSE.DRILLBLAST_OPERATOR_INCR_P(VARCHAR);

CREATE OR REPLACE PROCEDURE "DRILLBLAST_OPERATOR_INCR_P"("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var sp_result="";

var sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                      FROM TEST_API_REF.FUSE.drillblast_operator_incr 
                      WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

var sql_delete_incr = `DELETE FROM TEST_API_REF.FUSE.drillblast_operator_incr 
                       WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

var sql_merge = `MERGE INTO TEST_API_REF.FUSE.drillblast_operator_incr tgt
USING (
    SELECT system_operator_id, site_code, orig_src_id, application_operator_id,
           operator_name, crew_id, crew_name, sap_operator_id,
           effective_start_date, end_date, system_version,
           ''N'' AS dw_logical_delete_flag,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
           dw_modify_ts
    FROM prod_wg.drill_blast.drillblast_operator
    WHERE dw_modify_ts::date >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE)
) AS src
ON tgt.system_operator_id = src.system_operator_id AND tgt.site_code = src.site_code
WHEN MATCHED AND HASH(src.operator_name, src.crew_id, src.crew_name, src.sap_operator_id, src.end_date)
              <> HASH(tgt.operator_name, tgt.crew_id, tgt.crew_name, tgt.sap_operator_id, tgt.end_date)
THEN UPDATE SET
    tgt.orig_src_id = src.orig_src_id, tgt.application_operator_id = src.application_operator_id,
    tgt.operator_name = src.operator_name, tgt.crew_id = src.crew_id,
    tgt.crew_name = src.crew_name, tgt.sap_operator_id = src.sap_operator_id,
    tgt.effective_start_date = src.effective_start_date, tgt.end_date = src.end_date,
    tgt.system_version = src.system_version, tgt.dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
WHEN NOT MATCHED THEN INSERT (
    system_operator_id, site_code, orig_src_id, application_operator_id, operator_name,
    crew_id, crew_name, sap_operator_id, effective_start_date, end_date, system_version,
    dw_logical_delete_flag, dw_load_ts, dw_modify_ts
) VALUES (
    src.system_operator_id, src.site_code, src.orig_src_id, src.application_operator_id,
    src.operator_name, src.crew_id, src.crew_name, src.sap_operator_id,
    src.effective_start_date, src.end_date, src.system_version,
    src.dw_logical_delete_flag, src.dw_load_ts, src.dw_modify_ts
);`;

var sql_delete = `UPDATE TEST_API_REF.FUSE.drillblast_operator_incr tgt
                  SET dw_logical_delete_flag = ''Y'', dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
                  WHERE tgt.dw_logical_delete_flag = ''N''
                  AND NOT EXISTS (SELECT 1 FROM prod_wg.drill_blast.drillblast_operator src
                      WHERE src.system_operator_id = tgt.system_operator_id AND src.site_code = tgt.site_code);`;

try {
    snowflake.execute({sqlText: "BEGIN WORK;"});
    var rs_count_incr = snowflake.execute({sqlText: sql_count_incr});
    rs_count_incr.next();
    var rs_records_incr = rs_count_incr.getColumnValue(''COUNT_CHECK_1'');
    var rs_deleted_records_incr = rs_records_incr > 0 ? snowflake.execute({sqlText: sql_delete_incr}).getNumRowsAffected() : 0;
    var rs_merge = snowflake.execute({sqlText: sql_merge});
    var rs_merged_records = rs_merge.getNumRowsAffected();
    var rs_delete = snowflake.execute({sqlText: sql_delete});
    var rs_delete_records = rs_delete.getNumRowsAffected();
    sp_result = "Deleted: " + rs_deleted_records_incr + ", Merged: " + rs_merged_records + ", Archived: " + rs_delete_records;
    snowflake.execute({sqlText: "COMMIT WORK;"});
    return sp_result;
} catch (err) { snowflake.execute({sqlText: "ROLLBACK WORK;"}); throw err; }
';

-- ----------------------------------------------------------------------------
-- PROCEDURE: DRILLBLAST_SHIFT_INCR_P
-- ----------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS TEST_API_REF.FUSE.DRILLBLAST_SHIFT_INCR_P(VARCHAR);

CREATE OR REPLACE PROCEDURE "DRILLBLAST_SHIFT_INCR_P"("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var sp_result="";

var sql_merge = `MERGE INTO TEST_API_REF.FUSE.drillblast_shift_incr tgt
USING (
    SELECT orig_src_id, site_code, shift_id, shift_date, shift_name,
           shift_date_name, attributed_crew_id, crew_name, shift_no,
           shift_start_ts_utc::TIMESTAMP_NTZ AS shift_start_ts_utc,
           shift_end_ts_utc::TIMESTAMP_NTZ AS shift_end_ts_utc,
           shift_start_ts_local::TIMESTAMP_NTZ AS shift_start_ts_local,
           shift_end_ts_local::TIMESTAMP_NTZ AS shift_end_ts_local,
           system_version,
           ''N'' AS dw_logical_delete_flag,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
           dw_modify_ts::TIMESTAMP_NTZ AS dw_modify_ts
    FROM prod_wg.drill_blast.drillblast_shift
    WHERE dw_modify_ts >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_TIMESTAMP())
) AS src
ON tgt.site_code = src.site_code AND tgt.shift_id = src.shift_id
WHEN MATCHED THEN UPDATE SET
    tgt.orig_src_id = src.orig_src_id, tgt.shift_date = src.shift_date,
    tgt.shift_name = src.shift_name, tgt.shift_date_name = src.shift_date_name,
    tgt.attributed_crew_id = src.attributed_crew_id, tgt.crew_name = src.crew_name,
    tgt.shift_no = src.shift_no, tgt.shift_start_ts_utc = src.shift_start_ts_utc,
    tgt.shift_end_ts_utc = src.shift_end_ts_utc, tgt.shift_start_ts_local = src.shift_start_ts_local,
    tgt.shift_end_ts_local = src.shift_end_ts_local, tgt.system_version = src.system_version,
    tgt.dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
WHEN NOT MATCHED THEN INSERT (
    orig_src_id, site_code, shift_id, shift_date, shift_name, shift_date_name,
    attributed_crew_id, crew_name, shift_no, shift_start_ts_utc, shift_end_ts_utc,
    shift_start_ts_local, shift_end_ts_local, system_version,
    dw_logical_delete_flag, dw_load_ts, dw_modify_ts
) VALUES (
    src.orig_src_id, src.site_code, src.shift_id, src.shift_date, src.shift_name,
    src.shift_date_name, src.attributed_crew_id, src.crew_name, src.shift_no,
    src.shift_start_ts_utc, src.shift_end_ts_utc, src.shift_start_ts_local, src.shift_end_ts_local,
    src.system_version, src.dw_logical_delete_flag, src.dw_load_ts, src.dw_modify_ts
);`;

try {
    var rs_merge = snowflake.execute({sqlText: sql_merge});
    var rs_merged_records = rs_merge.getNumRowsAffected();
    sp_result = "Deleted: 0, Merged: " + rs_merged_records + ", Archived: 0";
    return sp_result;
} catch (err) { throw err; }
';

-- ----------------------------------------------------------------------------
-- PROCEDURE: LH_HAUL_CYCLE_INCR_P
-- ----------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS TEST_API_REF.FUSE.LH_HAUL_CYCLE_INCR_P(VARCHAR);

CREATE OR REPLACE PROCEDURE "LH_HAUL_CYCLE_INCR_P"("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
var sp_result="";

var sql_merge = `MERGE INTO TEST_API_REF.FUSE.lh_haul_cycle_incr tgt
USING (
    SELECT haul_cycle_id, site_code, orig_src_id, 
           shift_id_at_loading_end, shift_id_at_dump_end,
           material_id, routing_shape_id,
           loading_loc_id, loading_loc_name, loading_loc_coord_x, loading_loc_coord_y, loading_loc_elev, loading_method,
           dump_loc_id, dump_loc_name, dump_loc_coord_x, dump_loc_coord_y, dump_loc_elev,
           category_material, category_source_destination,
           excav_id, excav_operator_id, truck_id, truck_loading_operator_id, truck_dumping_operator_id,
           report_payload_short_tons, nominal_payload_short_tons, measured_payload_metric_tons,
           autonomous_flag, overload_flag,
           cycle_start_ts_utc::TIMESTAMP_NTZ AS cycle_start_ts_utc, 
           cycle_end_ts_utc::TIMESTAMP_NTZ AS cycle_end_ts_utc, 
           cycle_start_ts_local::TIMESTAMP_NTZ AS cycle_start_ts_local, 
           cycle_end_ts_local::TIMESTAMP_NTZ AS cycle_end_ts_local,
           empty_travel_start_ts_utc::TIMESTAMP_NTZ AS empty_travel_start_ts_utc, 
           empty_travel_end_ts_utc::TIMESTAMP_NTZ AS empty_travel_end_ts_utc, 
           empty_travel_start_ts_local::TIMESTAMP_NTZ AS empty_travel_start_ts_local, 
           empty_travel_end_ts_local::TIMESTAMP_NTZ AS empty_travel_end_ts_local,
           empty_travel_duration_ready_mins AS empty_travel_duration_mins,
           empty_travel_surface_dist_feet AS empty_travel_distance_feet,
           empty_travel_surface_dist_meters AS empty_travel_distance_meters,
           loading_start_ts_utc::TIMESTAMP_NTZ AS loading_start_ts_utc, 
           loading_end_ts_utc::TIMESTAMP_NTZ AS loading_end_ts_utc, 
           loading_start_ts_local::TIMESTAMP_NTZ AS loading_start_ts_local, 
           loading_end_ts_local::TIMESTAMP_NTZ AS loading_end_ts_local, 
           loading_duration_ready_mins AS loading_duration_mins,
           full_travel_start_ts_utc::TIMESTAMP_NTZ AS full_travel_start_ts_utc, 
           full_travel_end_ts_utc::TIMESTAMP_NTZ AS full_travel_end_ts_utc, 
           full_travel_start_ts_local::TIMESTAMP_NTZ AS full_travel_start_ts_local, 
           full_travel_end_ts_local::TIMESTAMP_NTZ AS full_travel_end_ts_local,
           full_travel_duration_ready_mins AS full_travel_duration_mins,
           full_travel_surface_dist_feet AS full_travel_distance_feet,
           full_travel_surface_dist_meters AS full_travel_distance_meters,
           dumping_start_ts_utc::TIMESTAMP_NTZ AS dumping_start_ts_utc, 
           dumping_end_ts_utc::TIMESTAMP_NTZ AS dumping_end_ts_utc, 
           dumping_start_ts_local::TIMESTAMP_NTZ AS dumping_start_ts_local, 
           dumping_end_ts_local::TIMESTAMP_NTZ AS dumping_end_ts_local, 
           dumping_duration_ready_mins AS dumping_duration_mins,
           total_cycle_duration_ready_mins AS cycle_duration_mins,
           delta_c_mins, fuel_used_in_cycle_gallons,
           tcu_pct, xcu_pct, 
           NULL AS insol_pct,
           system_version,
           ''N'' AS dw_logical_delete_flag,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
           dw_modify_ts::TIMESTAMP_NTZ AS dw_modify_ts
    FROM prod_wg.load_haul.lh_haul_cycle
    WHERE dw_modify_ts >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_TIMESTAMP())
) AS src
ON tgt.haul_cycle_id = src.haul_cycle_id
WHEN MATCHED THEN UPDATE SET
    tgt.site_code = src.site_code, tgt.material_id = src.material_id,
    tgt.report_payload_short_tons = src.report_payload_short_tons,
    tgt.cycle_end_ts_local = src.cycle_end_ts_local,
    tgt.dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
WHEN NOT MATCHED THEN INSERT (
    haul_cycle_id, site_code, orig_src_id, shift_id_at_loading_end, shift_id_at_dump_end,
    material_id, routing_shape_id, loading_loc_id, loading_loc_name, loading_loc_coord_x, loading_loc_coord_y, loading_loc_elev, loading_method,
    dump_loc_id, dump_loc_name, dump_loc_coord_x, dump_loc_coord_y, dump_loc_elev,
    category_material, category_source_destination, excav_id, excav_operator_id, truck_id, truck_loading_operator_id, truck_dumping_operator_id,
    report_payload_short_tons, nominal_payload_short_tons, measured_payload_metric_tons, autonomous_flag, overload_flag,
    cycle_start_ts_utc, cycle_end_ts_utc, cycle_start_ts_local, cycle_end_ts_local,
    empty_travel_start_ts_utc, empty_travel_end_ts_utc, empty_travel_start_ts_local, empty_travel_end_ts_local,
    empty_travel_duration_mins, empty_travel_distance_feet, empty_travel_distance_meters,
    loading_start_ts_utc, loading_end_ts_utc, loading_start_ts_local, loading_end_ts_local, loading_duration_mins,
    full_travel_start_ts_utc, full_travel_end_ts_utc, full_travel_start_ts_local, full_travel_end_ts_local,
    full_travel_duration_mins, full_travel_distance_feet, full_travel_distance_meters,
    dumping_start_ts_utc, dumping_end_ts_utc, dumping_start_ts_local, dumping_end_ts_local, dumping_duration_mins,
    cycle_duration_mins, delta_c_mins, fuel_used_in_cycle_gallons, tcu_pct, xcu_pct, insol_pct, system_version,
    dw_logical_delete_flag, dw_load_ts, dw_modify_ts
) VALUES (
    src.haul_cycle_id, src.site_code, src.orig_src_id, src.shift_id_at_loading_end, src.shift_id_at_dump_end,
    src.material_id, src.routing_shape_id, src.loading_loc_id, src.loading_loc_name, src.loading_loc_coord_x, src.loading_loc_coord_y, src.loading_loc_elev, src.loading_method,
    src.dump_loc_id, src.dump_loc_name, src.dump_loc_coord_x, src.dump_loc_coord_y, src.dump_loc_elev,
    src.category_material, src.category_source_destination, src.excav_id, src.excav_operator_id, src.truck_id, src.truck_loading_operator_id, src.truck_dumping_operator_id,
    src.report_payload_short_tons, src.nominal_payload_short_tons, src.measured_payload_metric_tons, src.autonomous_flag, src.overload_flag,
    src.cycle_start_ts_utc, src.cycle_end_ts_utc, src.cycle_start_ts_local, src.cycle_end_ts_local,
    src.empty_travel_start_ts_utc, src.empty_travel_end_ts_utc, src.empty_travel_start_ts_local, src.empty_travel_end_ts_local,
    src.empty_travel_duration_mins, src.empty_travel_distance_feet, src.empty_travel_distance_meters,
    src.loading_start_ts_utc, src.loading_end_ts_utc, src.loading_start_ts_local, src.loading_end_ts_local, src.loading_duration_mins,
    src.full_travel_start_ts_utc, src.full_travel_end_ts_utc, src.full_travel_start_ts_local, src.full_travel_end_ts_local,
    src.full_travel_duration_mins, src.full_travel_distance_feet, src.full_travel_distance_meters,
    src.dumping_start_ts_utc, src.dumping_end_ts_utc, src.dumping_start_ts_local, src.dumping_end_ts_local, src.dumping_duration_mins,
    src.cycle_duration_mins, src.delta_c_mins, src.fuel_used_in_cycle_gallons, src.tcu_pct, src.xcu_pct, src.insol_pct, src.system_version,
    src.dw_logical_delete_flag, src.dw_load_ts, src.dw_modify_ts
);`;

try {
    var rs_merge = snowflake.execute({sqlText: sql_merge});
    var rs_merged_records = rs_merge.getNumRowsAffected();
    sp_result = "Deleted: 0, Merged: " + rs_merged_records + ", Archived: 0";
    return sp_result;
} catch (err) { throw err; }
';



-- ============================================================================
-- SECTION 3: INITIAL LOAD (Run after deployment)
-- ============================================================================

-- Run each procedure with 30-day lookback for initial data load:

CALL TEST_API_REF.FUSE.BL_DW_BLAST_INCR_P('30');
CALL TEST_API_REF.FUSE.BL_DW_BLASTPROPERTYVALUE_INCR_P('30');
CALL TEST_API_REF.FUSE.BL_DW_HOLE_INCR_P('30');
CALL TEST_API_REF.FUSE.BLAST_PLAN_INCR_P('30');
CALL TEST_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR_P('30');
CALL TEST_API_REF.FUSE.DRILL_CYCLE_INCR_P('30');
CALL TEST_API_REF.FUSE.DRILL_PLAN_INCR_P('30');
CALL TEST_API_REF.FUSE.DRILLBLAST_EQUIPMENT_INCR_P('30');
CALL TEST_API_REF.FUSE.DRILLBLAST_OPERATOR_INCR_P('30');
CALL TEST_API_REF.FUSE.DRILLBLAST_SHIFT_INCR_P('30');
CALL TEST_API_REF.FUSE.LH_HAUL_CYCLE_INCR_P('30');


-- ============================================================================
-- SECTION 4: VALIDATION QUERIES
-- ============================================================================

-- Verify all tables exist
SELECT TABLE_NAME, ROW_COUNT, CREATED
FROM TEST_API_REF.INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'FUSE' 
AND TABLE_NAME LIKE '%_INCR'
ORDER BY TABLE_NAME;

-- Verify all procedures exist
SELECT PROCEDURE_NAME, ARGUMENT_SIGNATURE, CREATED
FROM TEST_API_REF.INFORMATION_SCHEMA.PROCEDURES 
WHERE PROCEDURE_SCHEMA = 'FUSE' 
AND PROCEDURE_NAME LIKE '%_INCR_P'
ORDER BY PROCEDURE_NAME;

-- Quick test one procedure
CALL TEST_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR_P('3');
