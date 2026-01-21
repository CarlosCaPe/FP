CREATE VIEW [sie].[CONOPS_SIE_SHIFT_SNAPSHOT_SEQ_V] AS



--SELECT * FROM [sie].[CONOPS_SIE_SHIFT_SNAPSHOT_SEQ_V] where shiftflag = 'curr' order by shiftseq asc

CREATE VIEW [sie].[CONOPS_SIE_SHIFT_SNAPSHOT_SEQ_V]
AS

SELECT 
  shiftsnap.shiftflag,
  shiftsnap.siteflag,
  shiftsnap.shiftid,
  --shiftsnap.tons,
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
      snap.TotalMaterialMoved as tons,
      CASE WHEN datediff(
        second, shiftinfo.ShiftStartDateTime,
        snap.shiftdumptime
      ) between timeseq.starts
      and timeseq.ends THEN timeseq.seq ELSE '999999' END AS shiftseq
    FROM
      [dbo].[SHIFT_INFO_V] shiftinfo (NOLOCK) CROSS
      JOIN [DBO].[TIME_SEQ] (NOLOCK) timeseq
      LEFT JOIN [sie].[CONOPS_SIE_SHIFT_SNAPSHOT_V] snap ON shiftinfo.shiftid = snap.shiftid --ON shiftinfo.shiftflag = timeseq.[shift]
      --WHERE shiftinfo.shiftflag = 'PREV'
	  WHERE shiftinfo.siteflag = 'SIE'
	  ) a
	  GROUP BY a.shiftflag,a.siteflag,a.shiftid,a.shiftseq

   UNION ALL



     SELECT shiftinfo.shiftflag,
      shiftinfo.siteflag,
      shiftinfo.shiftid,
      --NULL as shiftdumptime,
      --0 as [NrOfDumps],
      0 as tons,
      timeseq.seq as shiftseq
      from [dbo].[SHIFT_INFO_V] shiftinfo (NOLOCK) CROSS JOIN [DBO].[TIME_SEQ] (NOLOCK) timeseq
      --where shiftflag = 'CURR'
	  WHERE shiftinfo.siteflag = 'SIE'
	  


  ) shiftsnap --WHERE shiftsnap.shiftflag = 'PREV'
WHERE
  shiftsnap.shiftseq <> '999999'
  --AND shiftsnap.shiftflag = 'PREV'
GROUP BY
  shiftsnap.shiftflag,
  shiftsnap.siteflag,
  shiftsnap.shiftid,
  shiftsnap.shiftseq,
  shiftsnap.tons 
  --ORDER BY shiftsnap.shiftseq asc



--order by shiftflag,shiftseq

