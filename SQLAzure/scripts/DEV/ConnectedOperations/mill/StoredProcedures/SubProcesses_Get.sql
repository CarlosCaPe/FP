/******************************************************************  
* PROCEDURE	: mill.SubProcesses_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: pananda, 11 Sep 2024
* SAMPLE	: 
	1. EXEC mill.SubProcesses_Get 'MOR', 'en-US'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {11 Sep 2024}		{pananda}		{Initial Created}
*******************************************************************/ 
CREATE   PROCEDURE [mill].[SubProcesses_Get] 
(	
	@SiteCode VARCHAR(3),
	@LanguageCode VARCHAR(5)
)
AS                        
BEGIN    
	SELECT 
		P.ProcessId,
		COALESCE(PN.ProcessName, P.ProcessName) AS ProcessName,
		SP.SubProcessId,
		COALESCE(SPN.SubProcessName, SP.SubProcessName) AS SubProcessName,
		ROW_NUMBER() OVER (ORDER BY P.DisplayOrder, SP.DisplayOrder) AS DisplayOrder,
		SSP.IsEnabled
	FROM 
		[mill].SiteSubProcesses SSP
		JOIN [mill].SubProcesses SP
			ON SP.SubProcessId = SSP.SubProcessId
		JOIN [mill].Processes P
			ON P.ProcessId = SSP.ProcessId
		LEFT JOIN [mill].SubProcessName SPN
			ON SPN.SubProcessId = SP.SubProcessId AND SPN.LanguageCode = @LanguageCode
		LEFT JOIN [mill].ProcessName PN
			ON PN.ProcessId = P.ProcessId AND PN.LanguageCode = @LanguageCode
	WHERE 
		SSP.SiteCode = @SiteCode
		AND SSP.IsEnabled = 1
	ORDER BY
		P.DisplayOrder, SP.DisplayOrder
END

