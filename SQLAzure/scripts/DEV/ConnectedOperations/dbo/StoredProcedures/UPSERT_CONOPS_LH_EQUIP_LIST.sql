

/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_LH_EQUIP_LIST]
* PURPOSE	: Upsert [UPSERT_CONOPS_LH_EQUIP_LIST]
* NOTES     : 
* CREATED	: ggosal1
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_LH_EQUIP_LIST] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {14 JUL 2023}		{ggosal1}			{Initial Created}  
*******************************************************************/  
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_LH_EQUIP_LIST]
AS
BEGIN

DELETE FROM dbo.LH_EQUIP_LIST

INSERT INTO dbo.LH_EQUIP_LIST
SELECT [SHIFTINDEX]
      ,[SHIFTDATE]
      ,[SITE_CODE]
      ,[CLIID]
      ,[DDBKEY]
      ,[EQMTID]
      ,[EQMTID_ORIG]
      ,[EQMTTYPE]
      ,[EQMTTYPE_CODE]
      ,[EQMTTYPE_CODE_ORIG]
      ,[EQMTTYPE_ORIG]
      ,[EXTRALOAD]
      ,[PIT]
      ,[SIZE]
      ,[TRAMMER]
      ,[UNIT]
      ,[UNIT_CODE]
	  ,[UTC_CREATED_DATE]
FROM dbo.LH_EQUIP_LIST_STG
 
END


