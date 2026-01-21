







/******************************************************************  
* PROCEDURE  : dbo.QuickLinks_Get
* PURPOSE  : 
* NOTES    : 
* CREATED  : sxavier
* SAMPLE  : 
  1. EXEC dbo.QuickLinks_Get 'MOR', 'CON', 'MCF', 'EN'

* MODIFIED DATE     AUTHOR      DESCRIPTION  
*------------------------------------------------------------------  
* {24 Oct 2024}    {sxavier}    {Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[QuickLinks_Get]
(
  @SiteCode VARCHAR(3),
  @ProcessId VARCHAR(3),
  @SubProcessId VARCHAR(3),
  @LanguageCode VARCHAR(2)
)
AS                        
BEGIN          
SET NOCOUNT ON

  SELECT
    A.Id,
    A.GroupId,
    A.GroupTitle,
    A.Title,
    A.[Url]
  FROM
    dbo.QUICK_LINKS_V A
  WHERE
    A.SiteCode = @SiteCode
    AND A.ProcessId = @ProcessId
    AND A.SubProcessId = @SubProcessId
    AND A.LanguageCode = @LanguageCode
    AND A.GroupLanguageCode = @LanguageCode
  ORDER BY
    A.GroupDisplayOrder, A.DisplayOrder

SET NOCOUNT OFF
END


 
