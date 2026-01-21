CREATE VIEW [sie].[ZZZ_CONOPS_SIE_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V_OLD] AS






--select * from [sie].[CONOPS_SIE_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] WITH (NOLOCK)

CREATE VIEW [sie].[CONOPS_SIE_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V_OLD] 
AS
	WITH stc AS
	(
	    SELECT TOP 1
		substring(replace(cast(getdate() as date),'-',''),3,4) as shiftdate,
		0 AS [total]
		FROM [sie].[plan_values_prod_sum] WITH (NOLOCK)
		ORDER BY DateEffective DESC
	)

	SELECT [shift].shiftflag,
	       [shift].[siteflag],
		   [Location],
		   [Target]
	FROM [dbo].[SHIFT_INFO_V] [shift] WITH (NOLOCK)
	LEFT JOIN (
		SELECT stc.shiftdate,
			   --'SIE' [siteflag],
			   'Crusher' [Location], 
			   0 AS [Target]
			   --[stc].total + ((0.1*([stc].total + ip.total)) * ([stc].total/([stc].total + ip.total))) [Target]
		FROM stc
	) [C2]
	ON [C2].shiftdate = left([shift].shiftid,4) AND [shift].[siteflag] = 'SIE'
	WHERE [shift].[siteflag] = 'SIE'

