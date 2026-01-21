




/******************************************************************  
* PROCEDURE	: dbo.Equipment_Shovel_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 21 Mar 2023
* SAMPLE	: 
	1. EXEC dbo.Equipment_Shovel_Get 'CURR', 'BAG'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Mar 2023}		{lwasini}		{Initial Created}  
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Equipment_Shovel_Get_OLD] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN  
	DECLARE @SCHEMA VARCHAR(4);

	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;

	SET @SCHEMA = CASE @SITE 
					   WHEN 'CMX' THEN 'CLI'
					   ELSE @SITE
				  END;

EXEC (
' SELECT' 
+' shovelid,'
+' [location],'
+' operator,'
+' operatorimageURL,'
+' TonsPerReadyHour,'
+' TonsPerReadyHourTarget,'
+' TotalMaterialMined AS TonsMined,'
+' TotalMaterialMinedTarget AS TonsMinedTarget,'
+' payload,'
+' PayloadTarget,'
+' NumberOfLoads,'
+' UnderLoaded,'
+' BelowTarget,'
+' OnTarget,'
+' AboveTarget,'
+' OverLoaded,'
+' InvalidPayload,'
+' 0 AS ToothMetrics,'
+' UseOfAvailability,'
+' statusname,'
+' reasonid,'
+' reasondesc,'
+' TimeInState'
+' FROM '+@SCHEMA+'.[CONOPS_'+@SCHEMA+'_EQMT_SHOVEL_V]'
+' WHERE '
+' shiftflag = '''+@SHIFT+''''
+' AND siteflag = '''+@SITE+''''


);
END

