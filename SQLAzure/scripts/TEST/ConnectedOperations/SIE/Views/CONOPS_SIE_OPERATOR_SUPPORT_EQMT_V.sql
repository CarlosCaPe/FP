CREATE VIEW [SIE].[CONOPS_SIE_OPERATOR_SUPPORT_EQMT_V] AS






-- SELECT * FROM [SIE].[CONOPS_SIE_OPERATOR_SUPPORT_EQMT_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [SIE].[CONOPS_SIE_OPERATOR_SUPPORT_EQMT_V]
AS


SELECT 
	 [os].[shiftflag]
   	,[os].[siteflag]
   	,[os].[shiftid]
   	,[os].[SHIFTINDEX]
   	,[os].[SupportEquipmentId]
   	,[os].[StatusName]
   	,[os].[CrewName]
   	,[os].[Location]
   	,[os].[Operator]
   	,[os].[OperatorId]
   	,[os].[OperatorImageURL]
	,[os].[OperatorStatus]
	,[shift].[ShiftStartDateTime]
	,[shift].[ShiftEndDateTime]
FROM [SIE].[CONOPS_SIE_OPERATOR_SUPPORT_EQMT_LIST_V] [os]
LEFT JOIN [SIE].[CONOPS_SIE_SHIFT_INFO_V] [shift] 
	ON [os].shiftid = [shift].shiftid



