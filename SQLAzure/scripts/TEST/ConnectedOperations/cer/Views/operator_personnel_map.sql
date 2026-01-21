CREATE VIEW [cer].[operator_personnel_map] AS




CREATE VIEW [cer].[operator_personnel_map]
AS

SELECT DISTINCT
OPERATOR_ID, 
PERSONNEL_ID
FROM dbo.operator_personnel_map WITH (NOLOCK)
WHERE SITE_CODE = 'CER'


