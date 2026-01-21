







/******************************************************************  
* PROCEDURE	: [mill].MetcalfSecondaryCrusherInspectionForm_Add
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 15 Nov 2024
* SAMPLE	: 

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {15 Nov 2024}		{sxavier}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [mill].[MetcalfSecondaryCrusherInspectionForm_Add] 
(	
	@TransactionId INT,
	@SiteCode VARCHAR(3),
	@TransactionDate DATETIME,
	@ShiftId VARCHAR(3),
	@RawData VARCHAR(MAX),
	@AreaId VARCHAR(64),
	@ApronFeeder501 VARCHAR(MAX),
	@ApronFeeder601 VARCHAR(MAX),
	@ApronFeeder701 VARCHAR(MAX),
	@ScreenFeeder2120 VARCHAR(MAX),
	@ScreenFeeder2125 VARCHAR(MAX),
	@Screen2140 VARCHAR(MAX),
	@Screen2145 VARCHAR(MAX),
	@SecondaryCrusher1 VARCHAR(MAX),
	@SecondaryCrusher2 VARCHAR(MAX),
	@SecondaryCrusherMetalToMetal1 VARCHAR(MAX),
	@SecondaryCrusherMetalToMetal2 VARCHAR(MAX),
	@CrusherFeeder2190 VARCHAR(MAX),
	@CrusherFeeder2195 VARCHAR(MAX),
	@B5Tripper VARCHAR(MAX),
	@ChuteCheck VARCHAR(MAX),
	@R11Conveyor VARCHAR(MAX),
	@R1BConveyor VARCHAR(MAX),
	@R2Conveyor VARCHAR(MAX),
	@B1Conveyor VARCHAR(MAX),
	@B2Conveyor VARCHAR(MAX),
	@B3Conveyor VARCHAR(MAX),
	@B4Conveyor VARCHAR(MAX),
	@B5Conveyor VARCHAR(MAX),
	@InspectionComment VARCHAR(MAX),
	@CreatedBy CHAR(10),
	@UtcCreatedDate DATETIME,
	@ModifiedBy CHAR(10),
	@UtcModifiedDate DATETIME
)
AS                        
BEGIN          
	SET NOCOUNT ON
	SET XACT_ABORT ON

		BEGIN TRANSACTION	

		INSERT INTO mill.MetcalfSecondaryCrusherInspectionForm
		(	
			TransactionId,
			SiteCode,
			TransactionDate,
			ShiftId,
			RawData,
			AreaId,
			ApronFeeder501,
			ApronFeeder601,
			ApronFeeder701,
			ScreenFeeder2120,
			ScreenFeeder2125,
			Screen2140,
			Screen2145,
			SecondaryCrusher1,
			SecondaryCrusher2,
			SecondaryCrusherMetalToMetal1,
			SecondaryCrusherMetalToMetal2,
			CrusherFeeder2190,
			CrusherFeeder2195,
			B5Tripper,
			ChuteCheck,
			R11Conveyor,
			R1BConveyor,
			R2Conveyor,
			B1Conveyor,
			B2Conveyor,
			B3Conveyor,
			B4Conveyor,
			B5Conveyor,
			InspectionComment,
			CreatedBy,
			UtcCreatedDate,
			ModifiedBy,
			UtcModifiedDate
		)
		VALUES			
		( 	
			@TransactionId,
			@SiteCode,
			@TransactionDate,
			@ShiftId,
			@RawData,
			@AreaId,
			@ApronFeeder501,
			@ApronFeeder601,
			@ApronFeeder701,
			@ScreenFeeder2120,
			@ScreenFeeder2125,
			@Screen2140,
			@Screen2145,
			@SecondaryCrusher1,
			@SecondaryCrusher2,
			@SecondaryCrusherMetalToMetal1,
			@SecondaryCrusherMetalToMetal2,
			@CrusherFeeder2190,
			@CrusherFeeder2195,
			@B5Tripper,
			@ChuteCheck,
			@R11Conveyor,
			@R1BConveyor,
			@R2Conveyor,
			@B1Conveyor,
			@B2Conveyor,
			@B3Conveyor,
			@B4Conveyor,
			@B5Conveyor,
			@InspectionComment,
			@CreatedBy,
			@UtcCreatedDate,
			@ModifiedBy,
			@UtcModifiedDate
		)

		COMMIT TRANSACTION

	SET NOCOUNT OFF
END

