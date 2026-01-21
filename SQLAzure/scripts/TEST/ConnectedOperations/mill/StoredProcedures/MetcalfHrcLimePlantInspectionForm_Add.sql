







/******************************************************************  
* PROCEDURE	: [mill].MetcalfHrcLimePlantInspectionForm_Add
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 11 Dec 2024
* SAMPLE	: 

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {11 Dec 2024}		{sxavier}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [mill].[MetcalfHrcLimePlantInspectionForm_Add] 
(	
	@TransactionId INT,
	@SiteCode VARCHAR(3),
	@TransactionDate DATETIME,
	@RawData VARCHAR(MAX),
	@Hrc VARCHAR(MAX),
	@LimePlant VARCHAR(MAX),
	@DryFeeder VARCHAR(MAX),
	@DryFeederDustCollectors VARCHAR(MAX),
	@WetFeeders VARCHAR(MAX),
	@B6Conveyor VARCHAR(MAX),
	@B7Conveyor VARCHAR(MAX),
	@B8AConveyor VARCHAR(MAX),
	@B8BConveyor VARCHAR(MAX),
	@B9Conveyor VARCHAR(MAX),
	@B10Conveyor VARCHAR(MAX),
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

		INSERT INTO mill.MetcalfHrcLimePlantInspectionForm
		(	
			TransactionId,
			SiteCode,
			TransactionDate,
			RawData,
			Hrc,
			LimePlant,
			DryFeeder,
			DryFeederDustCollectors,
			WetFeeders,
			B6Conveyor,
			B7Conveyor,
			B8AConveyor,
			B8BConveyor,
			B9Conveyor,
			B10Conveyor,
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
			@RawData,
			@Hrc,
			@LimePlant,
			@DryFeeder,
			@DryFeederDustCollectors,
			@WetFeeders,
			@B6Conveyor,
			@B7Conveyor,
			@B8AConveyor,
			@B8BConveyor,
			@B9Conveyor,
			@B10Conveyor,
			@InspectionComment,
			@CreatedBy,
			@UtcCreatedDate,
			@ModifiedBy,
			@UtcModifiedDate
		)

		COMMIT TRANSACTION

	SET NOCOUNT OFF
END

