CREATE VIEW [dbo].[CONOPS_OVERALL_AVG_PAYLOAD_V] AS






--select * from [dbo].[CONOPS_OVERALL_AVG_PAYLOAD_V] WITH (NOLOCK) where shiftflag = 'prev'
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

UNION ALL

SELECT [pl].shiftflag,
	   [pl].siteflag,
	   FORMAT([AVG_Payload], '0.00') [AVG_Payload],
	   Target
FROM [saf].[CONOPS_SAF_OVERALL_AVG_PAYLOAD_V] [pl] WITH (NOLOCK)
WHERE [pl].siteflag = 'SAF'

UNION ALL

SELECT [pl].shiftflag,
	   [pl].siteflag,
	   FORMAT([AVG_Payload], '0.00') [AVG_Payload],
	   Target
FROM [sie].[CONOPS_SIE_OVERALL_AVG_PAYLOAD_V] [pl] WITH (NOLOCK)
WHERE [pl].siteflag = 'SIE'


UNION ALL

SELECT [pl].shiftflag,
	   [pl].siteflag,
	   FORMAT([AVG_Payload], '0.00') [AVG_Payload],
	   Target
FROM [cli].[CONOPS_CLI_OVERALL_AVG_PAYLOAD_V] [pl] WITH (NOLOCK)
WHERE [pl].siteflag = 'CMX'


UNION ALL

SELECT [pl].shiftflag,
	   [pl].siteflag,
	   FORMAT([AVG_Payload], '0.00') [AVG_Payload],
	   Target
FROM [cer].[CONOPS_CER_OVERALL_AVG_PAYLOAD_V] [pl] WITH (NOLOCK)
WHERE [pl].siteflag = 'CER'

UNION ALL

SELECT [pl].shiftflag,
	   [pl].siteflag,
	   FORMAT([AVG_Payload], '0.00') [AVG_Payload],
	   Target
FROM [chi].[CONOPS_CHI_OVERALL_AVG_PAYLOAD_V] [pl] WITH (NOLOCK)
WHERE [pl].siteflag = 'CHI'
