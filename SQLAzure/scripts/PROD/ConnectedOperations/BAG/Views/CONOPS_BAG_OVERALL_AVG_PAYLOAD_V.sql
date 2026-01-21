CREATE VIEW [BAG].[CONOPS_BAG_OVERALL_AVG_PAYLOAD_V] AS

--select * from [bag].[CONOPS_BAG_OVERALL_AVG_PAYLOAD_V] where shiftflag = 'curr'
CREATE VIEW [bag].[CONOPS_BAG_OVERALL_AVG_PAYLOAD_V] 
AS

SELECT
	si.ShiftFlag,
	si.SiteFlag,
	AVG(sc.MEASURED_PAYLOAD_SHORT_TONS) AS AVG_Payload,
	AVG(sc.REPORT_PAYLOAD_SHORT_TONS) AS [Target]
FROM BAG.CONOPS_BAG_SHIFT_INFO_V si
LEFT JOIN BAG.FLEET_SHOVEL_CYCLE_V sc
	ON si.shiftid = sc.shift_id
WHERE sc.PayloadFilter = 1
GROUP BY 
	si.ShiftFlag,
	si.SiteFlag

