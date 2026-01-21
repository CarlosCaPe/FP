CREATE VIEW [CER].[CONOPS_CER_SHIFT_SNAPSHOT_SEQ_V] AS


--SELECT * FROM [cer].[CONOPS_CER_SHIFT_SNAPSHOT_SEQ_V] where shiftflag = 'curr' order by shiftseq asc

CREATE VIEW [cer].[CONOPS_CER_SHIFT_SNAPSHOT_SEQ_V]
AS

SELECT 
  shiftsnap.shiftflag,
  shiftsnap.siteflag,
  shiftsnap.shiftid,
  shiftsnap.shiftseq,
  (
    sum(shiftsnap.tons) over ( partition by shiftsnap.shiftid
      order by
        shiftsnap.shiftseq
    )
  ) as runningtotal
FROM
  (

  SELECT 
  a.shiftflag,
  a.siteflag,
  a.shiftid,
  sum(a.tons) as tons,
  a.shiftseq
  FROM(
   SELECT
      shiftinfo.shiftflag,
      shiftinfo.siteflag,
      shiftinfo.shiftid,
      snap.shiftdumptime,
      snap.[NrOfDumps],
      snap.[TotalMaterialMined] as tons,
      CASE WHEN datediff(
        second, shiftinfo.ShiftStartDateTime,
        snap.shiftdumptime
      ) between timeseq.starts
      and timeseq.ends THEN timeseq.seq ELSE '999999' END AS shiftseq
    FROM
      [dbo].[SHIFT_INFO_V] shiftinfo (NOLOCK) CROSS
      JOIN [DBO].[TIME_SEQ] (NOLOCK) timeseq
      LEFT JOIN [cer].[CONOPS_CER_SHIFT_SNAPSHOT_V] snap ON shiftinfo.shiftid = snap.shiftid 
      
	  WHERE shiftinfo.siteflag = 'CER'
	  ) a
	  GROUP BY a.shiftflag,a.siteflag,a.shiftid,a.shiftseq

   UNION ALL



     SELECT shiftinfo.shiftflag,
      shiftinfo.siteflag,
      shiftinfo.shiftid,
      0 as tons,
      timeseq.seq as shiftseq
      from [dbo].[SHIFT_INFO_V] shiftinfo (NOLOCK) CROSS JOIN [DBO].[TIME_SEQ] (NOLOCK) timeseq
	  WHERE shiftinfo.siteflag = 'CER'
	  


  ) shiftsnap 
WHERE
  shiftsnap.shiftseq <> '999999'
  
GROUP BY
  shiftsnap.shiftflag,
  shiftsnap.siteflag,
  shiftsnap.shiftid,
  shiftsnap.shiftseq,
  shiftsnap.tons 
  

