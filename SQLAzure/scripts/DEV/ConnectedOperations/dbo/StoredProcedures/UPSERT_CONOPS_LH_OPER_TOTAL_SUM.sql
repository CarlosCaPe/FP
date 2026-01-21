


/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_LH_OPER_TOTAL_SUM]
* PURPOSE	: Upsert [UPSERT_CONOPS_LH_OPER_TOTAL_SUM]
* NOTES     : 
* CREATED	: mfahmi
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_LH_OPER_TOTAL_SUM]
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {01 DEC 2022}		{mfahmi}			{Initial Created}  
*******************************************************************/  
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_LH_OPER_TOTAL_SUM]
AS
BEGIN

DELETE FROM dbo.LH_OPER_TOTAL_SUM

INSERT INTO dbo.LH_OPER_TOTAL_SUM
SELECT 
	 SHIFTINDEX
	 ,SHIFTDATE
	 ,SITE_CODE
	 ,CLIID
	 ,DDBKEY
	 ,EQMTID
	 ,EQMTID_ORIG
	 ,IDLETIME
	 ,LOADCNT
	 ,LOADTIME
	 ,LOCID
	 ,LOGINTIME
	 ,NAME
	 ,OPERID
	 ,PIT
	 ,SPOTTIME
	 ,TMCAT00
	 ,TMCAT01
	 ,TMCAT02
	 ,TMCAT03
	 ,TMCAT04
	 ,TMCAT05
	 ,TMCAT06
	 ,TMCAT07
	 ,TMCAT08
	 ,TMCAT09
	 ,TMCAT10
	 ,TMCAT11
	 ,TMCAT12
	 ,TMCAT13
	 ,TMCAT14
	 ,TMCAT15
	 ,TMCAT16
	 ,TMCAT17
	 ,TMCAT18
	 ,TMCAT19
	 ,TOTALLOADS
	 ,TOTALTIME
	 ,TOTALTONS
	 ,UNIT
	 ,UNIT_CODE
	 ,SYSTEM_VERSION
	 ,UTC_CREATED_DATE
 FROM dbo.LH_OPER_TOTAL_SUM_stg
 
END


