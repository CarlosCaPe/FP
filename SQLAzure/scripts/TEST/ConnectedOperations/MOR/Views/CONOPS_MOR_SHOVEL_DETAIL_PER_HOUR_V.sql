CREATE VIEW [MOR].[CONOPS_MOR_SHOVEL_DETAIL_PER_HOUR_V] AS






-- SELECT * FROM [MOR].[CONOPS_MOR_SHOVEL_DETAIL_PER_HOUR_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR' ORDER BY [SHOVELID]
CREATE VIEW [mor].[CONOPS_MOR_SHOVEL_DETAIL_PER_HOUR_V]
AS

SELECT
	[tprh].shiftflag,
	[op].OperatorId,
	[tprh].EQMT AS ShovelId,
	[tprh].Hr,
	[p].Payload,
	[tprh].TPRH,
	[tmm].TotalMaterialMoved AS TonsMoved,
	[tmm].TotalMaterialMined AS TonsMined,
	[dc].idletime,
	[dc].spottime,
	[dc].loadtime,
	[dc].Hangtime,
	[ae].UofA AS UseofAvailability
FROM MOR.[CONOPS_MOR_EQMT_SHOVEL_HOURLY_TPRH_V] [tprh]
LEFT OUTER JOIN MOR.[CONOPS_MOR_OPERATOR_SHOVEL_LIST_V] [op]
	ON [tprh].shiftflag = [op].shiftflag AND [tprh].EQMT = [op].ShovelID
LEFT OUTER JOIN MOR.[CONOPS_MOR_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_V] [tmm]
	ON [tprh].shiftflag = [tmm].shiftflag AND [tprh].EQMT = [tmm].equipment AND [tprh].Hr = [tmm].TimeinHour
LEFT OUTER JOIN [mor].[CONOPS_MOR_HOURLY_TRUCK_ASSET_EFFICIENCY_V] [ae]
	ON [tprh].siteflag = [ae].siteflag 
	AND [tprh].shiftflag = [ae].shiftflag 
	AND [tprh].EQMT = [ae].Equipment 
	AND [tprh].Hr = [ae].Hr
	AND [ae].EqmtUnit = 2
LEFT OUTER JOIN MOR.[CONOPS_MOR_EQMT_SHOVEL_HOURLY_DELTAC_V] [dc]
	ON [tprh].shiftflag = [dc].shiftflag AND [tprh].EQMT = [dc].Equipment AND [tprh].Hr = [dc].deltac_ts
LEFT OUTER JOIN MOR.[CONOPS_MOR_EQMT_SHOVEL_HOURLY_PAYLOAD_V] [p]
	ON [tprh].shiftflag = [p].shiftflag AND [tprh].EQMT = [p].Equipment AND [tprh].Hr = [p].TimeinHour
WHERE [tprh].EQMT IS NOT NULL




