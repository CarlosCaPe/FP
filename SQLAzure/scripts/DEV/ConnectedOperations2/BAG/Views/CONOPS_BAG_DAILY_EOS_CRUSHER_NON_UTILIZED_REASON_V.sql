CREATE VIEW [BAG].[CONOPS_BAG_DAILY_EOS_CRUSHER_NON_UTILIZED_REASON_V] AS


  
  
  
  
--SELECT * FROM [BAG].[CONOPS_BAG_DAILY_EOS_CRUSHER_NON_UTILIZED_REASON_V] WHERE SHIFTFLAG = 'CURR'    
CREATE VIEW [bag].[CONOPS_BAG_DAILY_EOS_CRUSHER_NON_UTILIZED_REASON_V]    
AS    
    
SELECT
	s.shiftflag,
	c.siteflag,
	'Crusher' AS UnitType,
	NULL AS Reason,
	DATEDIFF(SS, COALESCE(c.StatusStart, s.SHIFTSTARTDATETIME), 
	CASE WHEN s.shiftflag = 'CURR' THEN GETDATE() ELSE s.SHIFTENDDATETIME END) / 3600.00 AS DurationHours
from bag.fleet_pit_machine_c c WITH (NOLOCK)
RIGHT JOIN bag.conops_bag_eos_shift_info_v s
	ON c.SHIFTID = s.SHIFTID
WHERE c.EquipmentId IN ('Crusher2', 'Crusher 2')
	AND c.statuscode IN (1, 3, 4)
  


