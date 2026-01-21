






/******************************************************************  
* PROCEDURE	: dbo.Equipment_ShovelDrillDown_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 21 Mar 2023
* SAMPLE	: 
	1. EXEC dbo.Equipment_ShovelDrillDown_Get 'PREV', 'BAG'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Mar 2023}		{lwasini}		{Initial Created}  
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Equipment_ShovelDrillDown_Get_OLD] 
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
+' operator,'
+' operatorimageURL,'
+' reasonid,'
+' comment,'
+' [location],'
+' ROUND(TimeInState,1) TimeInState,'
+' Crew,'
+' ROUND(payload,0) Payload,'
+' PayloadTarget,'
+' TonsPerReadyHour,'
+' TonsPerReadyHourTarget,'
+' TotalMaterialMined/1000.00 AS TonsMined,'
+' TotalMaterialMinedTarget/1000.00 AS TonsMinedTarget,'
+' NumberOfLoads,'
+' ROUND(Spotting,2) Spotting,'
+' SpottingTarget,'
+' ROUND(Loading,2) Loading,'
+' LoadingTarget,'
+' ROUND(IdleTime,2) IdleTime,'
+' IdleTimeTarget,'
+' TotalMaterialMoved AS TonsMoved,'
+' TotalMaterialMovedTarget AS TonsMovedTarget,'
+' ROUND(UseOfAvailability,0) UseOfAvailability,'
+' ToothMetrics'
+' FROM '+@SCHEMA+'.[CONOPS_'+@SCHEMA+'_EQMT_SHOVEL_V]'
+' WHERE '
+' shiftflag = '''+@SHIFT+''''
+' AND siteflag = '''+@SITE+''''
);

EXEC (
' SELECT'
+' Equipment,'
+' ROUND(Payload,0) Payload,'
+' TimeinHour'
+' FROM '+@SCHEMA+'.[CONOPS_'+@SCHEMA+'_EQMT_HOURLY_PAYLOAD_V]'
+' WHERE '
+' Equipment IS NOT NULL'
+' AND shiftflag = '''+@SHIFT+''''
+' AND siteflag = '''+@SITE+''''
+' ORDER BY Equipment,TimeinHour ASC'
);

EXEC (
' SELECT'
+' shovelid AS Equipment,'
+' ROUND(TotalMaterialMoved/1000.00,1) TonsMoved,'
+' ROUND(TotalMaterialMined/1000.00,1) TonsMined,'
+' TimeinHour'
+' FROM '+@SCHEMA+'.[CONOPS_'+@SCHEMA+'_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_V]'
+' WHERE '
+' shovelid IS NOT NULL'
+' AND shiftflag = '''+@SHIFT+''''
+' AND siteflag = '''+@SITE+''''
+' ORDER BY shovelid,TimeinHour ASC'
);

EXEC (
' SELECT'
+' EQMT AS Equipment,'
+' ROUND(TPRH,0) TPRH,'
+' Hr AS TimeinHour'
+' FROM '+@SCHEMA+'.[CONOPS_'+@SCHEMA+'_EQMT_SHOVEL_HOURLY_TPRH_V]'
+' WHERE '
+' EQMT IS NOT NULL'
+' AND shiftflag = '''+@SHIFT+''''
+' AND siteflag = '''+@SITE+''''
+' ORDER BY EQMT,Hr ASC'
);

EXEC (
' SELECT'
+' Equipment,'
+' NofLoad AS NumberofLoads,'
+' TimeinHour'
+' FROM '+@SCHEMA+'.[CONOPS_'+@SCHEMA+'_EQMT_HOURLY_NOFLOAD_V]'
+' WHERE '
+' Equipment IS NOT NULL'
+' AND shiftflag = '''+@SHIFT+''''
+' AND siteflag = '''+@SITE+''''
+' ORDER BY Equipment,TimeinHour ASC'
);

EXEC (
' SELECT'
+' Equipment,'
+' idletime,'
+' spottime,'
+' loadtime,'
+' deltac_ts AS TimeinHour'
+' FROM '+@SCHEMA+'.[CONOPS_'+@SCHEMA+'_EQMT_SHOVEL_HOURLY_DELTAC_V]'
+' WHERE '
+' Equipment IS NOT NULL'
+' AND shiftflag = '''+@SHIFT+''''
+' AND siteflag = '''+@SITE+''''
+' ORDER BY Equipment,deltac_ts ASC'
);

EXEC (
' SELECT'
+' Equipment,'
+' ROUND(UseofAvailability,0) UseofAvailability,'
+' TimeinHour'
+' FROM [dbo].[CONOPS_EQMT_SHOVEL_HOURLY_ASSET_EFFICIENCY_V]'
+' WHERE '
+' Equipment IS NOT NULL'
+' AND shiftflag = '''+@SHIFT+''''
+' AND siteflag = '''+@SITE+''''
+' ORDER BY Equipment,TimeinHour ASC'
);





END

