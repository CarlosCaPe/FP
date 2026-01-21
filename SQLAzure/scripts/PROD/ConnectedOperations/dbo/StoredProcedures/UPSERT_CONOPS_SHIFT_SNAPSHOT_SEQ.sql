   

/******************************************************************  
* PROCEDURE : [dbo].[UPSERT_CONOPS_SHIFT_SNAPSHOT_SEQ]
* PURPOSE : Upsert [UPSERT_CONOPS_SHIFT_SNAPSHOT_SEQ]
* NOTES : 
* CREATED : mfahmi
* SAMPLE: EXEC dbo.[UPSERT_CONOPS_SHIFT_SNAPSHOT_SEQ]
* MODIFIED DATE  AUTHORDESCRIPTION  
*------------------------------------------------------------------  
* {05 DEC 2022}  {mfahmi}   {Initial Created}   
* {10 JAN 2023}  {mfahmi}   {enhance schema table and remove site parameter}   
* {14 Nov 2025}  {ggosal1}  {Change Delete to Truncate}
*******************************************************************/  
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_SHIFT_SNAPSHOT_SEQ]

AS  
BEGIN  

TRUNCATE TABLE DBO.SHIFT_SNAPSHOT_SEQ;

INSERT INTO DBO.SHIFT_SNAPSHOT_SEQ
SELECT 
	siteflag,
	shiftid,
	shiftseq,
	runningtotal,
	UTC_CREATED_DATE
FROM DBO.SHIFT_SNAPSHOT_SEQ_STG

END

