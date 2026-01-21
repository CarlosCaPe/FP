

/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_SHIFT_DUMB]
* PURPOSE	: Upsert [UPSERT_CONOPS_SHIFT_DUMB]
* NOTES     : 
* CREATED	: lwasini
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_SHIFT_DUMB] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {25 OCT 2022}		{lwasini}			{Initial Created}  
*******************************************************************/  
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_SHIFT_DUMB]
(
@G_SITE VARCHAR(5)
)
AS
BEGIN
EXEC 
(
'MERGE ' + @G_SITE + '.shift_dumb AS T '
+' USING (SELECT '
+'  DbPrevious'
+' ,DbNext'
+' ,DbVersion'
+' ,ShiftId'
+' ,Id'
+' ,DbName'
+' ,DbKey'
+' ,FieldId'
+' ,FieldTruck'
+' ,FieldLoc'
+' ,FieldGrade'
+' ,FieldLoadrec'
+' ,FieldExcav'
+' ,FieldBlast'
+' ,FieldBay'
+' ,FieldTons'
+' ,FieldTimearrive'
+' ,FieldTimedump'
+' ,FieldTimeempty'
+' ,FieldTimedigest'
+' ,FieldCalctravtime'
+' ,FieldLoad'
+' ,FieldExtraload'
+' ,FieldDist'
+' ,FieldEfh'
+' ,FieldLoadtype'
+' ,FieldToper'
+' ,FieldEoper'
+' ,FieldOrigasn'
+' ,FieldReasnby'
+' ,FieldPathtravtime'
+' ,FieldExptraveltime'
+' ,FieldExptraveldist'
+' ,FieldGpstraveldist'
+' ,FieldLocactlc'
+' ,FieldLocacttp'
+' ,FieldLocactrl'
+' ,FieldAudit'
+' ,FieldGpsxtkd'
+' ,FieldGpsytkd'
+' ,FieldGpsstat'
+' ,FieldGpshead'
+' ,FieldGpsvel'
+' ,FieldLsizetons'
+' ,FieldLsizeid'
+' ,FieldLsizeversion'
+' ,FieldLsizedb'
+' ,FieldFactapply'
+' ,FieldDlock'
+' ,FieldElock'
+' ,FieldEdlock'
+' ,FieldRlock'
+' ,FieldReconstat'
+' ,FieldTimearrivemobile'
+' ,FieldTimedumpmobile'
+' ,FieldTimeemptymobile'
+' ,FieldMeasuretime'
+' ,FieldWeightst'
+' ,UTC_CREATED_DATE '
+' ,UTC_LOGICAL_DELETED_DATE'
+' FROM ' + @G_SITE + '.shift_dumb_stg'
+' WHERE CHANGE_TYPE IN (''U'',''I'')) AS S '
 +' ON (T.Id = S.Id ) '
+' WHEN MATCHED '
+' THEN UPDATE SET '
+' T.DbPrevious = S.DbPrevious'
+' ,T.DbNext = S.DbNext'
+' ,T.DbVersion = S.DbVersion'
+' ,T.ShiftId = S.ShiftId'
+' ,T.DbName = S.DbName'
+' ,T.DbKey = S.DbKey'
+' ,T.FieldId = S.FieldId'
+' ,T.FieldTruck = S.FieldTruck'
+' ,T.FieldLoc = S.FieldLoc'
+' ,T.FieldGrade = S.FieldGrade'
+' ,T.FieldLoadrec = S.FieldLoadrec'
+' ,T.FieldExcav = S.FieldExcav'
+' ,T.FieldBlast = S.FieldBlast'
+' ,T.FieldBay = S.FieldBay'
+' ,T.FieldTons = S.FieldTons'
+' ,T.FieldTimearrive = S.FieldTimearrive'
+' ,T.FieldTimedump = S.FieldTimedump'
+' ,T.FieldTimeempty = S.FieldTimeempty'
+' ,T.FieldTimedigest = S.FieldTimedigest'
+' ,T.FieldCalctravtime = S.FieldCalctravtime'
+' ,T.FieldLoad = S.FieldLoad'
+' ,T.FieldExtraload = S.FieldExtraload'
+' ,T.FieldDist = S.FieldDist'
+' ,T.FieldEfh = S.FieldEfh'
+' ,T.FieldLoadtype = S.FieldLoadtype'
+' ,T.FieldToper = S.FieldToper'
+' ,T.FieldEoper = S.FieldEoper'
+' ,T.FieldOrigasn = S.FieldOrigasn'
+' ,T.FieldReasnby = S.FieldReasnby'
+' ,T.FieldPathtravtime = S.FieldPathtravtime'
+' ,T.FieldExptraveltime = S.FieldExptraveltime'
+' ,T.FieldExptraveldist = S.FieldExptraveldist'
+' ,T.FieldGpstraveldist = S.FieldGpstraveldist'
+' ,T.FieldLocactlc = S.FieldLocactlc'
+' ,T.FieldLocacttp = S.FieldLocacttp'
+' ,T.FieldLocactrl = S.FieldLocactrl'
+' ,T.FieldAudit = S.FieldAudit'
+' ,T.FieldGpsxtkd = S.FieldGpsxtkd'
+' ,T.FieldGpsytkd = S.FieldGpsytkd'
+' ,T.FieldGpsstat = S.FieldGpsstat'
+' ,T.FieldGpshead = S.FieldGpshead'
+' ,T.FieldGpsvel = S.FieldGpsvel'
+' ,T.FieldLsizetons = S.FieldLsizetons'
+' ,T.FieldLsizeid = S.FieldLsizeid'
+' ,T.FieldLsizeversion = S.FieldLsizeversion'
+' ,T.FieldLsizedb = S.FieldLsizedb'
+' ,T.FieldFactapply = S.FieldFactapply'
+' ,T.FieldDlock = S.FieldDlock'
+' ,T.FieldElock = S.FieldElock'
+' ,T.FieldEdlock = S.FieldEdlock'
+' ,T.FieldRlock = S.FieldRlock'
+' ,T.FieldReconstat = S.FieldReconstat'
+' ,T.FieldTimearrivemobile = S.FieldTimearrivemobile'
+' ,T.FieldTimedumpmobile = S.FieldTimedumpmobile'
+' 