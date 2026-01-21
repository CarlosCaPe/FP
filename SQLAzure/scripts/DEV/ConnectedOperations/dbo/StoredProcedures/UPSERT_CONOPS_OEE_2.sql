
/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_OEE_2]
* PURPOSE	: Upsert [UPSERT_CONOPS_OEE_2]
* NOTES     : 
* CREATED	: mfahmi
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_OEE_2] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {28 NOV 2022}		{mfahmi}			{Initial Created}  
*******************************************************************/  
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_OEE_2]
AS
BEGIN

DELETE FROM dbo.OEE_2

INSERT INTO dbo.OEE_2
 SELECT 
 SITE_CODE
,SHIFTINDEX
,SHIFTDATE
,SHIFT
,READYTIME
,TOTALTIME
,SHOVELLOADCOUNT
,LOADERLOADCOUNT
,TOTALCYCLETIME
,DELTAC
,EQMT
,HOS
,CYCLECOUNT
,UTC_CREATED_DATE
 FROM dbo.OEE_stg_2
 
END




