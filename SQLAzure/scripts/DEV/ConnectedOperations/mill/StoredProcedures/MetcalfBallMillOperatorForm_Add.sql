






/******************************************************************  
* PROCEDURE	: [mill].MetcalfBallMillOperatorForm_Add
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 14 Oct 2024
* SAMPLE	: 

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {14 Oct 2024}		{sxavier}		{Initial Created}
* {22 Oct 2024}		{sxavier}		{Add Inspection Comment}
*******************************************************************/ 
CREATE PROCEDURE [mill].[MetcalfBallMillOperatorForm_Add] 
(	
	@TransactionId INT,
	@SiteCode VARCHAR(3),
	@TransactionDate DATETIME,
	@ShiftId VARCHAR(3),
	@RawData VARCHAR(MAX),
	@InspectionTimeId VARCHAR(64),
	@CyclonePack1 VARCHAR(MAX),
	@CyclonePack2 VARCHAR(MAX),
	@Mill1 VARCHAR(MAX),
	@Mill2 VARCHAR(MAX),
	@B11A VARCHAR(MAX),
	@B11B VARCHAR(MAX),
	@B12 VARCHAR(MAX),
	@B13 VARCHAR(MAX),
	@B14 VARCHAR(MAX),
	@Valves VARCHAR(MAX),
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

		INSERT INTO mill.MetcalfBallMillOperatorForm
		(	
			TransactionId,
			SiteCode,
			TransactionDate,
			ShiftId,
			RawData,
			InspectionTimeId,
			CyclonePack1,
			CyclonePack2,
			Mill1,
			Mill2,
			B11A,
			B11B,
			B12,
			B13,
			B14,
			Valves,
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
			@InspectionTimeId,
			@CyclonePack1,
			@CyclonePack2,
			@Mill1,
			@Mill2,
			@B11A,
			@B11B,
			@B12,
			@B13,
			@B14,
			@Valves,
			@InspectionComment,
			@CreatedBy,
			@UtcCreatedDate,
			@ModifiedBy,
			@UtcModifiedDate
		)

		COMMIT TRANSACTION

	SET NOCOUNT OFF
END

