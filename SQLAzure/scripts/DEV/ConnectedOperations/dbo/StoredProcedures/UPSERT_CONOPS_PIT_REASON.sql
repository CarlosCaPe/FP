



/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_PIT_REASON]
* PURPOSE	: Upsert [UPSERT_CONOPS_PIT_REASON]
* NOTES     : 
* CREATED	: mfahmi
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_PIT_REASON] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {17 JAN 2023}		{mfahmi}			{Initial Created}  
*******************************************************************/  
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_PIT_REASON]
AS
BEGIN

DELETE FROM dbo.PIT_REASON

INSERT INTO dbo.PIT_REASON
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
 FROM dbo.PIT_REASON_STG  
 
END



