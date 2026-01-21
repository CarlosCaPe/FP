
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

DELETE FROM dbo.PIT_REASON_2

INSERT INTO dbo.PIT_REASON_2
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
 
END




