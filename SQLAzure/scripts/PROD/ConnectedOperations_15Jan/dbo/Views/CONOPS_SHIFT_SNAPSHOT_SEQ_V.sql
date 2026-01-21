CREATE VIEW [dbo].[CONOPS_SHIFT_SNAPSHOT_SEQ_V] AS




--SELECT * FROM [dbo].[CONOPS_SHIFT_SNAPSHOT_SEQ_V] where shiftflag = 'curr' order by shiftseq asc  
  
CREATE VIEW [dbo].[CONOPS_SHIFT_SNAPSHOT_SEQ_V]  
AS  
  
SELECT   
siteflag,  
shiftid,  
shiftseq,  
runningtotal  
FROM [mor].[CONOPS_MOR_SHIFT_SNAPSHOT_SEQ_V]  


UNION ALL  
  
SELECT   
siteflag,  
shiftid,  
shiftseq,  
runningtotal  
FROM [bag].[CONOPS_BAG_SHIFT_SNAPSHOT_SEQ_V]  

  
  
UNION ALL  
  
SELECT   
siteflag,  
shiftid,  
shiftseq,  
runningtotal  
FROM [sie].[CONOPS_SIE_SHIFT_SNAPSHOT_SEQ_V]  

  
UNION ALL  
  
SELECT   
siteflag,  
shiftid,  
shiftseq,  
runningtotal  
FROM [saf].[CONOPS_SAF_SHIFT_SNAPSHOT_SEQ_V]  

  
  
UNION ALL  
  
SELECT   
siteflag,  
shiftid,  
shiftseq,  
runningtotal  
FROM [cli].[CONOPS_CLI_SHIFT_SNAPSHOT_SEQ_V]  


UNION ALL  
  
SELECT   
siteflag,  
shiftid,  
shiftseq,  
runningtotal  
FROM [cer].[CONOPS_CER_SHIFT_SNAPSHOT_SEQ_V]  

  
UNION ALL  
  
SELECT   
siteflag,  
shiftid,  
shiftseq,  
runningtotal  
FROM [chi].[CONOPS_CHI_SHIFT_SNAPSHOT_SEQ_V]  

  

