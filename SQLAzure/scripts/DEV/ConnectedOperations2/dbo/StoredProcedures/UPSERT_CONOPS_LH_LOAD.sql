
/******************************************************************      
* PROCEDURE : DBO.[UPSERT_CONOPS_LH_LOAD]    
* PURPOSE : UPSERT [UPSERT_CONOPS_LH_LOAD]    
* NOTES     :     
* CREATED : MFAHMI    
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_LH_LOAD]    
* MODIFIED DATE  AUTHOR    DESCRIPTION      
*------------------------------------------------------------------      
* {01 DEC 2022}  {MFAHMI}   {INITIAL CREATED} 
* {16 APR 2024}  {GGOSAL1}  {Remove PK}      
*******************************************************************/      

CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_LH_LOAD]    
AS    
BEGIN    
    
DELETE FROM dbo.LH_LOAD

INSERT INTO dbo.LH_LOAD
SELECT *
FROM dbo.LH_LOAD_STG
     
     
END    
    
