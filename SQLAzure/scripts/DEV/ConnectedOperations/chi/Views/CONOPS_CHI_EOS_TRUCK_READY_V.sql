CREATE VIEW [chi].[CONOPS_CHI_EOS_TRUCK_READY_V] AS
  
  
  
--SELECT * FROM [chi].[CONOPS_CHI_EOS_TRUCK_READY_V] WHERE shiftflag = 'curr' order by datetime  
CREATE VIEW [chi].[CONOPS_CHI_EOS_TRUCK_READY_V]  
AS  
  
WITH CTE AS (  
SELECT  
shiftid,  
eqmt,  
UnitType,  
StartDateTime  
FROM [chi].[asset_efficiency] WITH (NOLOCK)  
WHERE reasonidx = 200),  
  
TimeDiff AS (  
SELECT  
siteflag,  
shiftflag,  
ShiftStartDateTime,  
SHIFTENDDATETIME,  
eqmt,  
UnitType,  
datediff(minute, a.ShiftStartDateTime,StartDateTime) TimeDiff  
FROM [chi].CONOPS_CHI_SHIFT_INFO_V a  
LEFT JOIN CTE b  
ON a.shiftid = b.shiftid),  
  
TimeSeq AS (  
SELECT  
siteflag,  
shiftflag,  
ShiftStartDateTime,  
SHIFTENDDATETIME,  
eqmt,  
UnitType,  
CASE WHEN TimeDiff between b.starts and b.ends THEN b.seq   
ELSE '999999' END AS shiftseq  
FROM TimeDiff a  
CROSS JOIN [dbo].[HOURLY_TIME_SEQ] b WITH (NOLOCK)),  
  
Final AS (  
SELECT  
siteflag,  
shiftflag,  
ShiftStartDateTime,  
SHIFTENDDATETIME,  
COUNT(eqmt) Equipment,  
UnitType,  
shiftseq   
FROM TimeSeq  
WHERE shiftseq <> '999999'  
GROUP BY   
siteflag,  
shiftflag,  
ShiftStartDateTime,  
SHIFTENDDATETIME,  
UnitType,  
shiftseq)  
  
SELECT  
siteflag,  
shiftflag,  
ShiftStartDateTime,  
ShiftEndDateTime,  
Equipment,  
UnitType,  
dateadd(hour,shiftseq,ShiftStartDateTime) as [DateTime]  
FROM Final  
  
  
  
