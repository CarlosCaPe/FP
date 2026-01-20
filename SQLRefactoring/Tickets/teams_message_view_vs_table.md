Hi Vikas, Hidayath,

Following this morning's discussion, I've updated the tables for LH_BUCKET and LH_LOADING_CYCLE to use the new VIEW sources as requested, and renamed them to `_INCR`.

**TABLES**
• DEV_API_REF.FUSE.LH_BUCKET_INCR
• DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR

**PROCEDURES**
• DEV_API_REF.FUSE.LH_BUCKET_INCR_P(NUMBER_OF_DAYS VARCHAR DEFAULT '3')
• DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P(NUMBER_OF_DAYS VARCHAR DEFAULT '3')

**TASKS** (running every 15 min)
• DEV_API_REF.FUSE.LH_BUCKET_INCR_T ✅
• DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_T ✅

**Data Flow:**
```
PROD_WG.LOAD_HAUL.LH_BUCKET  ──MERGE(15min)──►  LH_BUCKET_INCR  ──SYNC──►  SQL Server
PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE  ──MERGE(15min)──►  LH_LOADING_CYCLE_INCR  ──SYNC──►  SQL Server
```

**Performance Results:**
No significant difference between old and new sources (~0.2-0.3s).

**Current Status:**
• LH_BUCKET_INCR: 54,436 rows
• LH_LOADING_CYCLE_INCR: 40,701 rows
• Tasks: Running ✅

**Cleanup:**
Old `_CT` objects have been removed (tables, procedures, and tasks).

Could you please review when you have a moment?

Best,
Carlos
