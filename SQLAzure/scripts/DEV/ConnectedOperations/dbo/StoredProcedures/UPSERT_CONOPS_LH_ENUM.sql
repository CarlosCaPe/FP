

/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_LH_ENUM]
* PURPOSE	: Upsert [UPSERT_CONOPS_LH_ENUM]
* NOTES     : 
* CREATED	: ggosal1
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_LH_ENUM] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {26 JUN 2023}		{ggosal1}			{Initial Created}  
*******************************************************************/  
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_LH_ENUM]
AS
BEGIN

DELETE FROM dbo.ENUM

INSERT INTO dbo.ENUM
SELECT 
	SHIFTDATE,
	SITE_CODE,
	CLIID,
	ENUMNAME,
	NUM,
	"NAME",
	ABBREV,
	FLAGS,
	UTC_CREATED_DATE
FROM dbo.ENUM_STG
 
END


