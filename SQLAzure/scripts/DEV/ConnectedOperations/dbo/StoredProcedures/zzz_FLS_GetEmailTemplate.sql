








/******************************************************************  
* PROCEDURE	: dbo.FLS_GetEmailTemplate
* PURPOSE	: 
* NOTES		: 
* CREATED	: ywibowo, 24 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_GetEmailTemplate 'EM01'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {24 Apr 2023}		{ywibowo}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_GetNotificationList] 
	@ID as CHAR(4)
AS                        
BEGIN    
	
	SET NOCOUNT ON

	SELECT
		ID,
		MailSubject,
		MailBody
	FROM 
		dbo.FLS_ViewEmailTemplate(NOLOCK)
	WHERE
		ID = @ID 
	
	SET NOCOUNT OFF

END

