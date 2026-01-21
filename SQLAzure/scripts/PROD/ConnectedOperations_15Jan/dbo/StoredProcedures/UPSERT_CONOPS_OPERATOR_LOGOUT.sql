








/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_OPERATOR_LOGOUT]
* PURPOSE	: Upsert [UPSERT_CONOPS_OPERATOR_LOGOUT]
* NOTES     : 
* CREATED	: ggosal1
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_OPERATOR_LOGOUT] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {06 JUN 2023}		{ggosal1}			{Initial Created}  
*******************************************************************/  
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_OPERATOR_LOGOUT]
AS
BEGIN

DELETE FROM dbo.OPERATOR_LOGOUT

INSERT INTO dbo.OPERATOR_LOGOUT
SELECT 
	site_code,
	shift_oper_id,
	shiftindex,
	shiftdate,
	operid,
	oper_name,
	crew,
	eqmt,
	fieldlogin,
	fieldlogin_ts,
	"status",
	utc_created_date
FROM dbo.OPERATOR_LOGOUT_STG
 
END



