  
  
  
/******************************************************************    
* PROCEDURE : dbo.Lookup_Importance_Get  
* PURPOSE :   
* NOTES  :   
* CREATED : elbert, 26 June 2023  
* SAMPLE :   
 1. EXEC dbo.Lookup_Importance_Get 'EN', 'MO'  
   
* MODIFIED DATE     AUTHOR   DESCRIPTION    
*------------------------------------------------------------------    
* {26 Jun 2023}  {elbert}  {Initial Created}  
* {07 Jul 2023}  {sxavier}  {Refactor query}  
* {07 Jul 2023}  {ywibowo}  {Code Review}  
* {02 Oct 2023}  {sxavier}  {Select from logbook lookup}  
*******************************************************************/   
CREATE PROCEDURE [dbo].[Lookup_Importance_Get]   
(   
 @LanguageCode char(2),  
 @LogbookType CHAR(2)  
)  
AS                          
BEGIN            
SET NOCOUNT ON  
  
 SELECT  
  TableCode,  
  [Description]  
 FROM   
  dbo.CONOPS_LOGBOOK_LOOKUPS_V  
 WHERE   
  LanguageCode = @LanguageCode AND   
  LogbookType = @LogbookType AND  
  TableType = 'IMPT' AND   
  IsActive = 1  
  
SET NOCOUNT OFF  
END  
  
  
