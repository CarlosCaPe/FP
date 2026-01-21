


/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_OPSPORTAL_SITE]
* PURPOSE	: Upsert [UPSERT_CONOPS_OPSPORTAL_SITE]
* NOTES     : 
* CREATED	: lwasini
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_OPSPORTAL_SITE] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {25 OCT 2022}		{lwasini}			{Initial Created}  
*******************************************************************/  
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_OPSPORTAL_SITE]
AS
BEGIN

MERGE dbo.OPSPORTAL_SITE AS T 
USING (SELECT 
	 site_code
	,site_offset_hour
	,UTC_CREATED_DATE 
 FROM dbo.OPSPORTAL_SITE_stg) AS S 
 ON (T.site_code = S.site_code ) 

 WHEN MATCHED 
 THEN UPDATE SET 
	 T.site_offset_hour = S.site_offset_hour
	,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE 
 WHEN NOT MATCHED 
 THEN INSERT ( 
	site_code
	,site_offset_hour
	,UTC_CREATED_DATE 
  ) VALUES( 
	 S.site_code
	,S.site_offset_hour
	,S.UTC_CREATED_DATE 
 ); 
 
END


