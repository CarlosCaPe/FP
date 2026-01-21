CREATE VIEW [dbo].[zzz_FLS_ViewEmailTemplate] AS






/******************************************************************  
* VIEW	    : dbo.[FLS_ViewEmailTemplate]
* PURPOSE	: 
* NOTES		: 
* CREATED	: ywibowo, 24 Apr 2023
* SAMPLE	: 
	1. SELECT * FROM dbo.[FLS_ViewEmailTemplate]
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {24 Apr 2023}		{ywibowo}		{Initial Created}
*******************************************************************/ 


CREATE VIEW [dbo].[FLS_ViewEmailTemplate]
AS
	SELECT
		ID,
		MailSubject,
		MailBody,
		[Description],
		CreatedBy,
		UtcCreatedDate,
		LastModifiedBy,
		UtcLastModifiedDate
	FROM [dbo].[FLS_EmailTemplate] (NOLOCK)

