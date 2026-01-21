

/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_LH_EQUIP_LIST_2]
* PURPOSE	: Upsert [UPSERT_CONOPS_LH_EQUIP_LIST_2]
* NOTES     : 
* CREATED	: ggosal1
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_LH_EQUIP_LIST_2] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {14 JUL 2023}		{ggosal1}			{Initial Created}  
*******************************************************************/  
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_LH_EQUIP_LIST_2]
AS
BEGIN

MERGE dbo.LH_EQUIP_LIST_2 AS T
USING (
    SELECT 
        [SHIFTINDEX], [SHIFTDATE], [SITE_CODE], [CLIID], [DDBKEY], [EQMTID], [EQMTID_ORIG],
        [EQMTTYPE], [EQMTTYPE_CODE], [EQMTTYPE_CODE_ORIG], [EQMTTYPE_ORIG], [EXTRALOAD],
        [PIT], [SIZE], [TRAMMER], [UNIT], [UNIT_CODE], [UTC_CREATED_DATE]
    FROM dbo.LH_EQUIP_LIST_STG_2
) AS S
ON (
    T.[SITE_CODE] = S.[SITE_CODE] AND
    T.[SHIFTINDEX] = S.[SHIFTINDEX] AND
    T.[EQMTID] = S.[EQMTID]
)
WHEN MATCHED THEN
    UPDATE SET
        T.[SHIFTDATE] = S.[SHIFTDATE],
        T.[CLIID] = S.[CLIID],
        T.[DDBKEY] = S.[DDBKEY],
        T.[EQMTID_ORIG] = S.[EQMTID_ORIG],
        T.[EQMTTYPE] = S.[EQMTTYPE],
        T.[EQMTTYPE_CODE] = S.[EQMTTYPE_CODE],
        T.[EQMTTYPE_CODE_ORIG] = S.[EQMTTYPE_CODE_ORIG],
        T.[EQMTTYPE_ORIG] = S.[EQMTTYPE_ORIG],
        T.[EXTRALOAD] = S.[EXTRALOAD],
        T.[PIT] = S.[PIT],
        T.[SIZE] = S.[SIZE],
        T.[TRAMMER] = S.[TRAMMER],
        T.[UNIT] = S.[UNIT],
        T.[UNIT_CODE] = S.[UNIT_CODE],
        T.[UTC_CREATED_DATE] = S.[UTC_CREATED_DATE]
WHEN NOT MATCHED THEN
    INSERT (
        [SHIFTINDEX], [SHIFTDATE], [SITE_CODE], [CLIID], [DDBKEY], [EQMTID], [EQMTID_ORIG],
        [EQMTTYPE], [EQMTTYPE_CODE], [EQMTTYPE_CODE_ORIG], [EQMTTYPE_ORIG], [EXTRALOAD],
        [PIT], [SIZE], [TRAMMER], [UNIT], [UNIT_CODE], [UTC_CREATED_DATE]
    )
    VALUES (
        S.[SHIFTINDEX], S.[SHIFTDATE], S.[SITE_CODE], S.[CLIID], S.[DDBKEY], S.[EQMTID], S.[EQMTID_ORIG],
        S.[EQMTTYPE], S.[EQMTTYPE_CODE], S.[EQMTTYPE_CODE_ORIG], S.[EQMTTYPE_ORIG], S.[EXTRALOAD],
        S.[PIT], S.[SIZE], S.[TRAMMER], S.[UNIT], S.[UNIT_CODE], S.[UTC_CREATED_DATE]
    )
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;

--Update Job Control
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'job_conops_lh_equip_list_2';

END



