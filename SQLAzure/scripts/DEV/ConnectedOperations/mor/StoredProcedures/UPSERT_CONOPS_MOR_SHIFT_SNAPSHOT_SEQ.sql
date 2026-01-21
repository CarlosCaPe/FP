


/******************************************************************  
* PROCEDURE : mor.[UPSERT_CONOPS_SHIFT_SNAPSHOT_SEQ]
* PURPOSE	: Upsert [UPSERT_CONOPS_SHIFT_SNAPSHOT_SEQ]
* NOTES     : 
* CREATED	: mfahmi
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_SHIFT_SNAPSHOT_SEQ]
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {05 DEC 2022}		{mfahmi}			{Initial Created}  
*******************************************************************/  
CREATE  PROCEDURE [mor].[UPSERT_CONOPS_MOR_SHIFT_SNAPSHOT_SEQ]
AS
BEGIN

DELETE FROM mor.SHIFT_SNAPSHOT_SEQ

INSERT INTO mor.SHIFT_SNAPSHOT_SEQ
SELECT 
	 shiftflag,
	 siteflag,
	 shiftid,
	 shiftseq,
	 runningtotal,
	 UTC_CREATED_DATE
 FROM mor.SHIFT_SNAPSHOT_SEQ_STG
 
END


