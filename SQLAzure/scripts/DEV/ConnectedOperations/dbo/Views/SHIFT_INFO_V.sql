CREATE VIEW [dbo].[SHIFT_INFO_V] AS







--select * from [dbo].[SHIFT_INFO_V]  where siteflag = 'MOR'
  
CREATE VIEW [dbo].[SHIFT_INFO_V] 
AS  
 
SELECT   
siteflag,  
shiftflag,  
shiftid,  
(CONVERT(int, (DATEDIFF(DD, '7/12/2007', CAST(ShiftStartDateTime as DATE))*2) + 27412 + (SELECT RIGHT([ShiftId],1) - 1))) ShiftIndex,  
ShiftStartDateTime,  
ShiftEndDateTime,  
ShiftDuration  
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] (NOLOCK)  
where siteflag = 'MOR'  
  
UNION ALL  
  
  
SELECT   
siteflag,  
shiftflag,  
shiftid,  
(CONVERT(int, (DATEDIFF(DD, '7/12/2007', CAST(ShiftStartDateTime as DATE))*2) + 27412 + (SELECT RIGHT([ShiftId],1) - 1))) ShiftIndex,  
ShiftStartDateTime,  
ShiftEndDateTime,  
ShiftDuration  
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] (NOLOCK)  
where siteflag = 'BAG'  
  
UNION ALL  
  
  
SELECT   
siteflag,  
shiftflag,  
shiftid,  
(CONVERT(int, (DATEDIFF(DD, '7/12/2007', CAST(ShiftStartDateTime as DATE))*2) + 27412 + (SELECT RIGHT([ShiftId],1) - 1))) ShiftIndex,  
ShiftStartDateTime,  
ShiftEndDateTime,  
ShiftDuration  
FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] (NOLOCK)  
where siteflag = 'SAF'  
  
  
UNION ALL  
  
  
SELECT   
siteflag,  
shiftflag,  
shiftid,  
(CONVERT(int, (DATEDIFF(DD, '7/12/2007', CAST(ShiftStartDateTime as DATE))*2) + 27412 + (SELECT RIGHT([ShiftId],1) - 1)))*10 ShiftIndex,  
ShiftStartDateTime,  
ShiftEndDateTime,  
ShiftDuration  
FROM [cer].[CONOPS_CER_SHIFT_INFO_V] (NOLOCK)  
where siteflag = 'CER'  
  
  
UNION ALL  
  
  
SELECT   
siteflag,  
shiftflag,  
shiftid,  
(CONVERT(int, (DATEDIFF(DD, '7/12/2007', CAST(ShiftStartDateTime as DATE))*2) + 27412 + (SELECT RIGHT([ShiftId],1) - 1))) ShiftIndex,  
ShiftStartDateTime,  
ShiftEndDateTime,  
ShiftDuration  
FROM [sie].[CONOPS_SIE_SHIFT_INFO_V] (NOLOCK)  
where siteflag = 'SIE'  


UNION ALL  
  
  
SELECT   
siteflag,  
shiftflag,  
shiftid,  
(CONVERT(int, (DATEDIFF(DD, '7/12/2007', CAST(ShiftStartDateTime as DATE))*2) + 27412 + (SELECT RIGHT([ShiftId],1) - 1))) ShiftIndex,  
ShiftStartDateTime,  
ShiftEndDateTime,  
ShiftDuration  
FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] (NOLOCK)  
where siteflag = 'CMX'  


UNION ALL  
  
  
SELECT   
siteflag,  
shiftflag,  
shiftid,  
(CONVERT(int, (DATEDIFF(DD, '7/12/2007', CAST(ShiftStartDateTime as DATE))*2) + 27412 + (SELECT RIGHT([ShiftId],1) - 1))) ShiftIndex,  
ShiftStartDateTime,  
ShiftEndDateTime,  
ShiftDuration  
FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] (NOLOCK)  
where siteflag = 'CHI' 

UNION ALL  
  
  
SELECT   
siteflag,  
shiftflag,  
shiftid,  
(CONVERT(int, (DATEDIFF(DD, '7/12/2007', CAST(ShiftStartDateTime as DATE))*2) + 27412 + (SELECT RIGHT([ShiftId],1) - 1))) ShiftIndex,  
ShiftStartDateTime,  
ShiftEndDateTime,  
ShiftDuration  
FROM [ABR].[CONOPS_ABR_SHIFT_INFO_V] (NOLOCK)  
where siteflag = 'ABR' 

UNION ALL  
  
  
SELECT   
siteflag,  
shiftflag,  
shiftid,  
(CONVERT(int, (DATEDIFF(DD, '7/12/2007', CAST(ShiftStartDateTime as DATE))*2) + 27412 + (SELECT RIGHT([ShiftId],1) - 1))) ShiftIndex,  
ShiftStartDateTime,  
ShiftEndDateTime,  
ShiftDuration  
FROM [TYR].[CONOPS_TYR_SHIFT_INFO_V] (NOLOCK)  
where siteflag = 'TYR' 
  
