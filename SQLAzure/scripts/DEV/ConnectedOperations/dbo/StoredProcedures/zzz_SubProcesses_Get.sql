/******************************************************************  
* PROCEDURE	: mill.SubProcesses_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: pananda, 11 Sep 2024
* SAMPLE	: 
	1. EXEC mill.SubProcesses_Get 'MOR', 'en'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {11 Sep 2024}		{pananda}		{Initial Created}
*******************************************************************/ 
CREATE   PROCEDURE [dbo].[SubProcesses_Get] 
(	
	@SiteCode VARCHAR(3),
	@LanguageCode VARCHAR(5)
)
AS                        
BEGIN    
	SELECT 
		P.ProcessId,
		COALESCE(PN.ProcessName, P.ProcessName) AS ProcessName,
		P.ProcessIcon,
		P.ProcessColor,
		SP.SubProcessId,
		COALESCE(SPN.SubProcessName, SP.SubProcessName) AS SubProcessName,
		ROW_NUMBER() OVER (ORDER BY P.DisplayOrder, SP.DisplayOrder) AS DisplayOrder
	FROM 
		[mill].SITE_SUB_PROCESSES SSP
		JOIN [mill].SUB_PROCESSES SP
			ON SP.SubProcessId = SSP.SubProcessId
		JOIN [mill].PROCESSES P
			ON P.ProcessId = SSP.ProcessId
		LEFT JOIN [mill].SUB_PROCESS_NAME SPN
			ON SPN.SubProcessId = SP.SubProcessId AND SPN.LanguageCode = @LanguageCode
		LEFT JOIN [mill].PROCESS_NAME PN
			ON PN.ProcessId = P.ProcessId AND PN.LanguageCode = @LanguageCode
	WHERE 
		SSP.SiteCode = @SiteCode
	ORDER BY
		P.DisplayOrder, SP.DisplayOrder
END

