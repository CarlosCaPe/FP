CREATE VIEW [dbo].[CONOPS_TRUCK_DUMPING_TO_CRUSHER_V] AS


--select * from [dbo].[CONOPS_MOR_TRUCK_DUMPING_TO_CRUSHER_V]
CREATE VIEW [dbo].[CONOPS_TRUCK_DUMPING_TO_CRUSHER_V]
AS
SELECT shiftflag,
	   siteflag,
	   [Truck],
	   [totalDump]
FROM [mor].[CONOPS_MOR_TRUCK_DUMPING_TO_CRUSHER_V]
WHERE siteflag = 'MOR'

