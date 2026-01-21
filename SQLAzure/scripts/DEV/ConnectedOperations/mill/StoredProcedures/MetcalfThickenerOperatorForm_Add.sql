







/******************************************************************  
* PROCEDURE	: [mill].MetcalfThickenerOperatorForm_Add
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 20 Dec 2024
* SAMPLE	: 

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {20 Dec 2024}		{sxavier}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [mill].[MetcalfThickenerOperatorForm_Add] 
(	
	@TransactionId INT,
	@SiteCode VARCHAR(3),
	@TransactionDate DATETIME,
	@RawData VARCHAR(MAX),
	@ThickenerOperatorLogId VARCHAR(64),
	@ConcentrateThickener VARCHAR(MAX),
	@Clarifier VARCHAR(MAX),
	@Thickener5010 VARCHAR(MAX),
	@Thickener5011 VARCHAR(MAX),
	@DeadThickener VARCHAR(MAX),
	@Flocculant VARCHAR(MAX),
	@SumpPump4340 VARCHAR(MAX),
	@CleanWeir VARCHAR(MAX),
	@ReclaimPumps VARCHAR(MAX),
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

		INSERT INTO mill.MetcalfThickenerOperatorForm
		(	
			TransactionId,
			SiteCode,
			TransactionDate,
			RawData,
			ThickenerOperatorLogId,
			ConcentrateThickener,
			Clarifier,
			[5010Thickener],
			[5011Thickener],
			DeadThickener,
			Flocculant,
			[4340SumpPump],
			CleanWeir,
			ReclaimPumps,
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
			@ThickenerOperatorLogId,
			@ConcentrateThickener,
			@Clarifier,
			@Thickener5010,
			@Thickener5011,
			@DeadThickener,
			@Flocculant,
			@SumpPump4340,
			@CleanWeir,
			@ReclaimPumps,
			@InspectionComment,
			@CreatedBy,
			@UtcCreatedDate,
			@ModifiedBy,
			@UtcModifiedDate
		)

		COMMIT TRANSACTION

	SET NOCOUNT OFF
END

