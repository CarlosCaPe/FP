CREATE VIEW [SAF].[CONOPS_SAF_OPERATOR_SUPPORT_EQMT_V] AS






-- SELECT * FROM [SAF].[CONOPS_SAF_OPERATOR_SUPPORT_EQMT_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [SAF].[CONOPS_SAF_OPERATOR_SUPPORT_EQMT_V]
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
FROM [SAF].[CONOPS_SAF_OPERATOR_SUPPORT_EQMT_LIST_V] [os]
LEFT JOIN [SAF].[CONOPS_SAF_SHIFT_INFO_V] [shift] 
	ON [os].shiftid = [shift].shiftid



