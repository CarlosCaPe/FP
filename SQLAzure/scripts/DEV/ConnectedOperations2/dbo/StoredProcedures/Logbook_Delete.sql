  
  
  
  
/******************************************************************    
* PROCEDURE : dbo.Logbook_Delete  
* PURPOSE :   
* NOTES  :   
* CREATED : elbert, 26 June 2023  
* SAMPLE :   
 1. EXEC dbo.Logbook_Delete '24'  
  
* MODIFIED DATE     AUTHOR   DESCRIPTION    
*------------------------------------------------------------------    
* {26 Jun 2023}  {elbert}  {Initial Created}  
* {07 Jul 2023}  {sxavier}  {Refactor query}  
* {07 Jul 2023}  {ywibowo}  {Code Review}  
* {05 Sep 2023}  {sxavier}  {Add delete from dbo.LOGBOOK_ATTACHMENTS}  
* {02 Oct 2023}  {ywibowo}  {Code Review}  
*******************************************************************/   
CREATE PROCEDURE [dbo].[Logbook_Delete]   
(   
 @Id INT  
)  
AS                          
BEGIN            
 SET NOCOUNT ON  
 SET XACT_ABORT ON  
    
  BEGIN TRANSACTION  
  
  DELETE FROM   
   dbo.LOGBOOK_ATTACHMENTS  
  WHERE   
   LogbookId = @Id  
  
  DELETE FROM   
   dbo.LOGBOOK   
  WHERE   
   Id = @Id  
  
  COMMIT TRANSACTION  
  
 SET NOCOUNT OFF  
END  
  
  
