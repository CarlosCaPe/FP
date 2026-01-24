"""
Create BL_DW_HOLE_INCR table (fixed ROW keyword)
"""

import snowflake.connector
from dotenv import load_dotenv

load_dotenv()

SNOWFLAKE_CONFIG = {
    "account": "fcx.west-us-2.azure",
    "user": "CCARRILL2@fmi.com",
    "authenticator": "externalbrowser",
    "warehouse": "WH_BATCH_DE_NONPROD",
    "database": "DEV_API_REF",
    "schema": "FUSE",
    "role": "SG-AZW-SFLK-ENG-GENERAL",
}

CREATE_TABLE_SQL = """
CREATE OR REPLACE TABLE DEV_API_REF.FUSE.BL_DW_HOLE_INCR (
    ORIG_SRC_ID                         NUMBER(19,0) NOT NULL,
    SITE_CODE                           VARCHAR(50) COLLATE 'en-ci' NOT NULL,
    ID                                  NUMBER(10,0) NOT NULL,
    NAME                                VARCHAR(500) COLLATE 'en-ci',
    MODIFIED_NAME                       VARCHAR(500) COLLATE 'en-ci',
    BLASTNAME                           VARCHAR(500) COLLATE 'en-ci',
    MODIFIED_BLASTNAME                  VARCHAR(500) COLLATE 'en-ci',
    BLASTID                             NUMBER(10,0),
    "ROW"                               VARCHAR(500) COLLATE 'en-ci',
    ECHELON                             NUMBER(10,0),
    STATUS                              VARCHAR(500) COLLATE 'en-ci',
    LASTKNOWNDEPTH                      FLOAT,
    LASTKNOWNWATER                      FLOAT,
    LASTKNOWNWETSIDES                   FLOAT,
    LASTKNOWNTEMPERATURE                FLOAT,
    LASTKNOWNTEMPERATURETIME            TIMESTAMP_NTZ(9),
    PREVIOUSTEMPERATURE                 FLOAT,
    PREVIOUSTEMPERATURETIME             TIMESTAMP_NTZ(9),
    TEMPERATURERATEOFCHANGE             FLOAT,
    DESIGNTIME                          TIMESTAMP_NTZ(9),
    DRILLEDTIME                         TIMESTAMP_NTZ(9),
    LASTDIPDEPTH                        FLOAT,
    LASTDIPPEDTIME                      TIMESTAMP_NTZ(9),
    LASTBACKFILLINGDIPDEPTH             FLOAT,
    LASTBACKFILLINGDIPTIME              TIMESTAMP_NTZ(9),
    LASTCHARGINGDIPDEPTH                FLOAT,
    LASTCHARGINGDIPTIME                 TIMESTAMP_NTZ(9),
    CHARGEDTIME                         TIMESTAMP_NTZ(9),
    FIREDTIME                           TIMESTAMP_NTZ(9),
    ABANDONEDTIME                       TIMESTAMP_NTZ(9),
    ABANDONEDCOMMENT                    VARCHAR(5000) COLLATE 'en-ci',
    MISFIRE                             BOOLEAN,
    MISFIRECOMMENT                      VARCHAR(5000) COLLATE 'en-ci',
    REDRILLOFHOLEID                     NUMBER(10,0),
    REDRILLOFHOLENAME                   VARCHAR(500) COLLATE 'en-ci',
    ISADHOC                             BOOLEAN,
    DESIGNCOLLARX                       FLOAT,
    DESIGNCOLLARY                       FLOAT,
    DESIGNCOLLARZ                       FLOAT,
    DESIGNANGLE                         FLOAT,
    DESIGNBEARING                       FLOAT,
    DESIGNDEPTH                         FLOAT,
    DESIGNDIAMETER                      FLOAT,
    DESIGNBURDEN                        FLOAT,
    DESIGNSPACING                       FLOAT,
    ACTUALCOLLARX                       FLOAT,
    ACTUALCOLLARY                       FLOAT,
    ACTUALCOLLARZ                       FLOAT,
    TARGETCHARGEDEPTH                   FLOAT,
    PLANNEDPRIMERCOUNT                  NUMBER(10,0),
    LOADEDPRIMERCOUNT                   NUMBER(10,0),
    LOADEDEXPLOSIVEDECKCOUNT            NUMBER(10,0),
    DIPPEDOUTSIDECHARGEDEPTHTOLERANCE   BOOLEAN,
    CHARGEDOUTSIDEMASSTOLERANCE         BOOLEAN,
    DRILLEDOUTSIDECOLLARTOLERANCE       BOOLEAN,
    TOPMOSTSTEMMINGDECKLOADED           BOOLEAN,
    STEMMEDOUTSIDELENGTHTOLERANCE       BOOLEAN,
    EXPLOSIVEMASSDESIGNED               FLOAT,
    EXPLOSIVEMASSLOADED                 FLOAT,
    EXPLOSIVEMASSRECONCILED             FLOAT,
    STEMMINGLENGTHDESIGNED              FLOAT,
    STEMMINGLENGTHLOADED                FLOAT,
    STEMMINGLENGTHRECONCILED            FLOAT,
    DESIGNTIEUPCOUNT                    NUMBER(10,0),
    ACTUALTIEUPCOUNT                    NUMBER(10,0),
    DESIGNDRILLCOST                     NUMBER(15,5),
    CHARGESTANDOFF                      FLOAT,
    CHARGESTANDOFFDIRECTION             VARCHAR(50) COLLATE 'en-ci',
    REFRESHEDTIME                       TIMESTAMP_NTZ(9),
    DELETED                             BOOLEAN,
    DW_FILE_TS_UTC                      TIMESTAMP_NTZ(9),
    DW_LOGICAL_DELETE_FLAG              VARCHAR(1) COLLATE 'en-ci' DEFAULT 'N',
    DW_LOAD_TS                          TIMESTAMP_NTZ(0),
    DW_MODIFY_TS                        TIMESTAMP_NTZ(0)
)
COMMENT = 'Incremental table for BL_DW_HOLE - Drill hole details within blasts';
"""

print("Connecting to Snowflake...")
conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
cursor = conn.cursor()
print("Connected!")

cursor.execute("USE DATABASE DEV_API_REF;")
cursor.execute("USE SCHEMA FUSE;")

print("Creating BL_DW_HOLE_INCR table...")
cursor.execute(CREATE_TABLE_SQL)
print("✅ Table created!")

# Verify
cursor.execute("""
    SELECT TABLE_NAME FROM DEV_API_REF.INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA = 'FUSE' AND TABLE_NAME LIKE '%_INCR'
    ORDER BY TABLE_NAME
""")
tables = [row[0] for row in cursor.fetchall()]
print(f"\n📊 Total INCR Tables: {len(tables)}")
for t in tables:
    print(f"  ✅ {t}")

cursor.close()
conn.close()
print("\n🎉 Done!")
