CREATE VIEW [dbo].[CONOPS_OVERALL_AVG_PAYLOAD_V] AS


CREATE VIEW [dbo].[CONOPS_OVERALL_AVG_PAYLOAD_V]
AS

SELECT [pl].shiftflag,
	   [pl].siteflag,
	   FORMAT([AVG_Payload], '0.00') [AVG_Payload],
	   Target
FROM [mor].[CONOPS_MOR_OVERALL_AVG_PAYLOAD_V] [pl] WITH (NOLOCK)
WHERE [pl].siteflag = 'MOR'

UNION ALL

SELECT [pl].shiftflag,
	   [pl].siteflag,
	   FORMAT([AVG_Payload], '0.00') [AVG_Payload],
	   Target
FROM [bag].[CONOPS_BAG_OVERALL_AVG_PAYLOAD_V] [pl] WITH (NOLOCK)
WHERE [pl].siteflag = 'BAG'


