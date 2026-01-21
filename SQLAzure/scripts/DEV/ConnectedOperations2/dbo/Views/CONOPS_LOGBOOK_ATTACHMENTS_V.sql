CREATE VIEW [dbo].[CONOPS_LOGBOOK_ATTACHMENTS_V] AS
  
  
/******************************************************************    
* VIEW     : dbo.CONOPS_LOGBOOK_ATTACHMENTS_V  
* PURPOSE :   
* NOTES  :   
* CREATED : sxavier, 04 Sep 2023  
* SAMPLE :   
 1. SELECT * FROM dbo.CONOPS_LOGBOOK_V  
   
* MODIFIED DATE     AUTHOR   DESCRIPTION    
*------------------------------------------------------------------    
* {04 Sep 2023}  {sxavier}  {Initial Created}  
* {29 Sep 2023}  {ywibowo}  {Code Review}  
*******************************************************************/   
  
  
CREATE VIEW [dbo].[CONOPS_LOGBOOK_ATTACHMENTS_V]  
AS  
 SELECT  
  A.Id,  
  A.LogbookId,  
  A.Title,  
  A.AttachmentUrl,  
  A.CreatedBy,  
  A.UtcCreatedDate,  
  A.ModifiedBy,  
  A.UtcModifiedDate  
 FROM [dbo].[LOGBOOK_ATTACHMENTS] A (NOLOCK)  
  
