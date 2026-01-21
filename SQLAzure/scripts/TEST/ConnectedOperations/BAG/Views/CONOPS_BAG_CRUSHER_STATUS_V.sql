CREATE VIEW [BAG].[CONOPS_BAG_CRUSHER_STATUS_V] AS




--SELECT * FROM [BAG].[CONOPS_BAG_CRUSHER_STATUS_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [BAG].[CONOPS_BAG_CRUSHER_STATUS_V]  
AS  

SELECT 
c.siteflag,
s.shiftflag,
c.shiftindex,
CASE WHEN c.EquipmentID = 'Crusher2' 
	THEN 'Crusher 2'
	ELSE c.EquipmentID
END AS Crusher,
CASE c.StatusCode 
	WHEN 0 THEN 'Unknown'
	WHEN 1 THEN 'Down'
	WHEN 2 THEN 'Ready'
	WHEN 3 THEN 'Spare'
	WHEN 4 THEN 'Delay'
	WHEN 5 THEN 'Shiftchange'
END AS Status,
'' AS Reasons,
NULL AS ShovelId,
COALESCE(c.StatusStart, s.SHIFTSTARTDATETIME) AS StatusStart
FROM bag.fleet_pit_machine_c c WITH (NOLOCK)
RIGHT JOIN BAG.CONOPS_BAG_SHIFT_INFO_V s
	ON c.SHIFTID = s.SHIFTID
WHERE c.EQMTTYPE = 'Crusher'

