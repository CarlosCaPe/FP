CREATE VIEW [cli].[CONOPS_CLI_OPERATOR_SUPPORT_EQMT_V] AS





-- SELECT * FROM [CLI].[CONOPS_CLI_OPERATOR_SUPPORT_EQMT_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [CLI].[CONOPS_CLI_OPERATOR_SUPPORT_EQMT_V]
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
FROM [CLI].[CONOPS_CLI_OPERATOR_SUPPORT_EQMT_LIST_V] [os]
LEFT JOIN [CLI].[CONOPS_CLI_SHIFT_INFO_V] [shift] 
	ON [os].shiftid = [shift].shiftid


