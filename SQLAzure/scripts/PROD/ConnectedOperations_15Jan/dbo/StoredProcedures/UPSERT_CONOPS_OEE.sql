



/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_OEE]
* PURPOSE	: Upsert [UPSERT_CONOPS_OEE]
* NOTES     : 
* CREATED	: mfahmi
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_OEE] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {28 NOV 2022}		{mfahmi}			{Initial Created}  
*******************************************************************/  
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_OEE]
AS
BEGIN

DELETE FROM dbo.OEE

INSERT INTO dbo.OEE
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
 FROM dbo.OEE_stg  
 
END



