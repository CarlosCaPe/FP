



/******************************************************************  
* PROCEDURE	: dbo.CONOPS_LH_TP_DELTA_C
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.CONOPS_LH_TP_DELTA_C 'PREV', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}  
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CONOPS_LH_TP_DELTA_C] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN    
	 
	 
	select avg(a.delta_c) as delta_c,b.Delta_c_target
	FROM(
	select shiftflag,siteflag,shiftid,truck,delta_c
	from [dbo].[CONOPS_LH_DELTA_C_V]
	WHERE siteflag = @SITE) a
	LEFT JOIN (
	SELECT substring(replace(Date_Effective,'-',''),3,4) as shiftdate,Delta_C as Delta_c_target
	FROM [mor].[target_prod_summary] ) b
	on left(a.shiftid,4) = b.shiftdate
	WHERE a.shiftflag = @SHIFT
	AND a.siteflag = @SITE
	group by a.shiftflag,a.siteflag,a.shiftid,b.Delta_c_target;


	select TOP 15 truck,toper,avg(delta_c) as delta_c
	from [dbo].[CONOPS_LH_DELTA_C_V]
	WHERE shiftflag = @SHIFT
	AND siteflag = @SITE
	group by shiftflag,siteflag,shiftid,truck,toper
	order by avg(delta_c) desc;


SET NOCOUNT OFF
END

