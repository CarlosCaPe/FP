


/******************************************************************  
* PROCEDURE	: dbo.Conops_Target_Checking_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 18 Sep 2024
* SAMPLE	: 
	1. EXEC dbo.Conops_Target_Checking_Get 'PREV', 'MOR', 'Load and Haul', 'EN'
	2. EXEC dbo.Conops_Target_Checking_Get 'PREV', 'MOR', 'Load and Haul', 'ES'
	3. EXEC dbo.Conops_Target_Checking_Get 'PREV', 'MOR', 'Drill and Blast', 'EN'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {18 Sep 2024}		{ggosal1}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Conops_Target_Checking_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@PAGE VARCHAR(50),
	@LANG CHAR(2)
)
AS                        
BEGIN          
	
	IF @SITE = 'BAG'
	BEGIN

		SELECT 1
		

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 1

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT 1

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT 1

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT
			tm.TargetName,
			tm.RelatedCardList,
			tl.value AS TargetValue,
			tm.TargetDesc,
			tm.TargetSource,
			ts.SourceType,
			ts.SourceURL
		FROM [MOR].[CONOPS_MOR_TARGET_MAPPING_V] tm
		INNER JOIN MOR.CONOPS_MOR_SHIFT_INFO_V si
			ON tm.siteflag = si.siteflag
		LEFT JOIN [MOR].[CONOPS_MOR_TARGET_LIST_V] tl
			ON si.SHIFTID = tl.shiftid
			AND tm.TargetName = tl.target
		LEFT JOIN dbo.CONOPS_TARGET_SOURCE ts
			ON tm.siteflag = ts.siteflag
			AND tm.TargetSource = ts.SourceName
		WHERE si.shiftflag = @SHIFT
		AND [Page] = @PAGE
		AND LanguageCode = @LANG
		--AND value IS NULL
		
	END

	ELSE IF @SITE = 'SAM'
	BEGIN

		SELECT 1

	END

	ELSE IF @SITE = 'SIE'
	BEGIN

		SELECT 1

	END


	ELSE IF @SITE = 'TYR'
	BEGIN

		SELECT 1

	END


	ELSE IF @SITE = 'ABR'
	BEGIN

		SELECT 1

	END

END




