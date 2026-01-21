CREATE VIEW [mor].[CONOPS_MOR_TARGET_MAPPING_V] AS

--SELECT * FROM [MOR].[CONOPS_MOR_TARGET_MAPPING_V]
CREATE VIEW [MOR].[CONOPS_MOR_TARGET_MAPPING_V]
AS

WITH SplitCardIds AS(
SELECT
	SiteFlag,
	Page,
	TargetName,
	TargetSource,
	TargetDesc,
    CardId,
    value AS SplitCardId
FROM 
    [dbo].[CONOPS_TARGET_LIST] WITH(NOLOCK)
CROSS APPLY 
    STRING_SPLIT(CardId, ',')
)

SELECT
	sc.SiteFlag,
	sc.Page,
	sc.TargetName,
	sc.TargetSource,
	sc.TargetDesc,
	sc.CardId,
	ch.LanguageCode,
	STRING_AGG(ch.CardTitle, ', ') AS RelatedCardList
FROM SplitCardIds sc
LEFT JOIN dbo.CARDS_HEADER ch WITH(NOLOCK)
	ON sc.SplitCardId = ch.CardId
GROUP BY 
sc.SiteFlag,
sc.Page,
sc.TargetName,
sc.TargetSource,
sc.TargetDesc,
sc.CardId,
ch.LanguageCode