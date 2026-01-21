
/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_PIT_REASON_2]
* PURPOSE	: Upsert [UPSERT_CONOPS_PIT_REASON_2]
* NOTES     : 
* CREATED	: mfahmi
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_PIT_REASON_2] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {17 JAN 2023}		{mfahmi}			{Initial Created}  
*******************************************************************/  
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_PIT_REASON_2]
AS
BEGIN
MERGE dbo.PIT_REASON_2 AS T
USING (
    SELECT 
        ORIG_SRC_ID,
        SITE_CODE,
        STATUS,
        PIT_REASON_ID,
        DBPREVIOUS,
        DBNEXT,
        DBVERSION,
        PIT_DBNAME,
        DBKEY,
        FIELDID,
        FIELDDELAYTIME,
        FIELDCATEGORY,
        FIELDNAME,
        FIELDMAINTTIME,
        FIELDAUTO,
        FIELDDFCT,
        FIELDGCINCL,
        FIELDALTNAME,
        FIELDEXPECTDUR,
        FIELDTASK,
        FIELDLRINCL,
        FIELDICON,
        FIELDFTYPE,
        UTC_CREATED_DATE
    FROM dbo.PIT_REASON_STG_2
) AS S
ON (
    T.SITE_CODE = S.SITE_CODE AND
    T.PIT_REASON_ID = S.PIT_REASON_ID
)
WHEN MATCHED THEN
    UPDATE SET
        T.ORIG_SRC_ID = S.ORIG_SRC_ID,
        T.STATUS = S.STATUS,
        T.DBPREVIOUS = S.DBPREVIOUS,
        T.DBNEXT = S.DBNEXT,
        T.DBVERSION = S.DBVERSION,
        T.PIT_DBNAME = S.PIT_DBNAME,
        T.DBKEY = S.DBKEY,
        T.FIELDID = S.FIELDID,
        T.FIELDDELAYTIME = S.FIELDDELAYTIME,
        T.FIELDCATEGORY = S.FIELDCATEGORY,
        T.FIELDNAME = S.FIELDNAME,
        T.FIELDMAINTTIME = S.FIELDMAINTTIME,
        T.FIELDAUTO = S.FIELDAUTO,
        T.FIELDDFCT = S.FIELDDFCT,
        T.FIELDGCINCL = S.FIELDGCINCL,
        T.FIELDALTNAME = S.FIELDALTNAME,
        T.FIELDEXPECTDUR = S.FIELDEXPECTDUR,
        T.FIELDTASK = S.FIELDTASK,
        T.FIELDLRINCL = S.FIELDLRINCL,
        T.FIELDICON = S.FIELDICON,
        T.FIELDFTYPE = S.FIELDFTYPE,
        T.UTC_CREATED_DATE = S.UTC_CREATED_DATE
WHEN NOT MATCHED THEN
    INSERT (
        ORIG_SRC_ID,
        SITE_CODE,
        STATUS,
        PIT_REASON_ID,
        DBPREVIOUS,
        DBNEXT,
        DBVERSION,
        PIT_DBNAME,
        DBKEY,
        FIELDID,
        FIELDDELAYTIME,
        FIELDCATEGORY,
        FIELDNAME,
        FIELDMAINTTIME,
        FIELDAUTO,
        FIELDDFCT,
        FIELDGCINCL,
        FIELDALTNAME,
        FIELDEXPECTDUR,
        FIELDTASK,
        FIELDLRINCL,
        FIELDICON,
        FIELDFTYPE,
        UTC_CREATED_DATE
    )
    VALUES (
        S.ORIG_SRC_ID,
        S.SITE_CODE,
        S.STATUS,
        S.PIT_REASON_ID,
        S.DBPREVIOUS,
        S.DBNEXT,
        S.DBVERSION,
        S.PIT_DBNAME,
        S.DBKEY,
        S.FIELDID,
        S.FIELDDELAYTIME,
        S.FIELDCATEGORY,
        S.FIELDNAME,
        S.FIELDMAINTTIME,
        S.FIELDAUTO,
        S.FIELDDFCT,
        S.FIELDGCINCL,
        S.FIELDALTNAME,
        S.FIELDEXPECTDUR,
        S.FIELDTASK,
        S.FIELDLRINCL,
        S.FIELDICON,
        S.FIELDFTYPE,
        S.UTC_CREATED_DATE
    )
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;

--Update Job Control
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'job_conops_pit_reason_2';

END

