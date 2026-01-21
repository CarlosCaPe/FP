







/******************************************************************  
* PROCEDURE	: dbo.FLS_GetDefaultApprovers
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 18 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_GetDefaultApprovers
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {18 Apr 2023}		{sxavier}		{Initial Created} 
* {24 Apr 2023}		{ywibowo}		{Added column [Description]} 
* {24 Apr 2023}		{ywibowo}		{Code review} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_GetDefaultApprovers] 
(
	@TableType CHAR(4) = 'DLPD' --Default approver list for daily production module.
)
AS                        
BEGIN    
	
	SET NOCOUNT ON

	--DECLARE @ApproverAlias VARCHAR(MAX)

	--Get approver alias for multiple approvers.
	--SET @ApproverAlias = (SELECT [Value] FROM FLS_ViewLookups WHERE TableType = 'APTL' AND TableCode = '0' AND TableExtension = 'EN')

	SELECT
		TableExtension AS [Sequence], 
		[value] AS ApproverID
		--@ApproverAlias AS ApproverAlias
	FROM 
		dbo.FLS_ViewLookups (NOLOCK)
	WHERE
		TableType = @TableType 
		and TableCode = '0'
	ORDER BY Sequence

	SET NOCOUNT OFF

END

