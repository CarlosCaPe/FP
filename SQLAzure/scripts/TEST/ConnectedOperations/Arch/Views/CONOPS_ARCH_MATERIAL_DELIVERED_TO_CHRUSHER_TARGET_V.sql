CREATE VIEW [Arch].[CONOPS_ARCH_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] AS


CREATE VIEW [Arch].[CONOPS_ARCH_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V]
AS
	SELECT [shift].shiftflag,
	       [shift].[siteflag],
		   [Location],
		   [Target]
	FROM [dbo].[SHIFT_INFO_V] [shift] WITH (NOLOCK)
	LEFT JOIN (
		SELECT FORMATSHIFTID,
			   '<SITECODE>' [siteflag],
			   'Crusher 2' [Location], 
			   CRUSHER2 [Target]
		FROM [Arch].[plan_values] WITH (NOLOCK)
	) [C2]
	ON [C2].FORMATSHIFTID = [shift].[ShiftID] AND [C2].[siteflag] = [shift].[siteflag]
	WHERE [C2].[siteflag] = '<SITECODE>'

