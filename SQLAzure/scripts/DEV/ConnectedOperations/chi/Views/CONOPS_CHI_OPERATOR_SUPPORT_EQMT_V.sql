CREATE VIEW [chi].[CONOPS_CHI_OPERATOR_SUPPORT_EQMT_V] AS





-- SELECT * FROM [CHI].[CONOPS_CHI_OPERATOR_SUPPORT_EQMT_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [CHI].[CONOPS_CHI_OPERATOR_SUPPORT_EQMT_V]
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
FROM [CHI].[CONOPS_CHI_OPERATOR_SUPPORT_EQMT_LIST_V] [os]
LEFT JOIN [CHI].[CONOPS_CHI_SHIFT_INFO_V] [shift] 
	ON [os].shiftid = [shift].shiftid


