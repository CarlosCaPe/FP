CREATE VIEW [dbo].[QUICK_LINKS_V] AS
 
 
 
 
 
 
 
 
 
 
 
/******************************************************************  
* VIEW     : dbo.QUICK_LINKS_V
* PURPOSE : 
* NOTES  : 
* CREATED : sxavier, 24 Oct 2024
* SAMPLE : 
 1. SELECT * FROM dbo.QUICK_LINKS_V
* MODIFIED DATE     AUTHOR   DESCRIPTION  
*------------------------------------------------------------------  
* {24 Oct 2024}  {sxavier}  {Initial Created}
* {13 Dec 2024}  {sxavier}  {Add Quick Links Group}
*******************************************************************/
 
 
CREATE VIEW [dbo].[QUICK_LINKS_V]
AS
 SELECT
  A.Id,
  A.SiteCode,
  A.ProcessId,
  A.SubProcessId,
  C.Id AS GroupId,
  D.Title AS GroupTitle,
  D.LanguageCOde AS GroupLanguageCode,
  C.DisplayOrder AS GroupDisplayOrder,
  B.LanguageCode,
  B.Title,
  A.[Url],
  A.DisplayOrder,
  A.CreatedBy,
  A.UtcCreatedDate,
  A.ModifiedBy,
  A.UtcModifiedDate
 FROM dbo.QuickLinks A (NOLOCK)
 LEFT JOIN dbo.QuickLinksName B (NOLOCK) ON A.Id = B.Id
 LEFT JOIN dbo.QuickLinksGroup C (NOLOCK) ON A.QuickLinksGroupId = C.Id
 LEFT JOIN dbo.QuickLinksGroupName D (NOLOCK) ON A.QuickLinksGroupId = D.Id
 
