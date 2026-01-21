







/******************************************************************  
* PROCEDURE	: [mill].MetcalfThickenerUnderflowInspectionForm_Add
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 19 Dec 2024
* SAMPLE	: 

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {19 Dec 2024}		{sxavier}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [mill].[MetcalfThickenerUnderflowInspectionForm_Add] 
(	
	@TransactionId INT,
	@SiteCode VARCHAR(3),
	@TransactionDate DATETIME,
	@RawData VARCHAR(MAX),
	@Thickener5010 VARCHAR(MAX),
	@Thickener5011 VARCHAR(MAX),
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

		INSERT INTO mill.MetcalfThickenerUnderflowInspectionForm
		(	
			TransactionId,
			SiteCode,
			TransactionDate,
			RawData,
			[5010Thickener],
			[5011Thickener],
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
			@Thickener5010,
			@Thickener5011,
			@InspectionComment,
			@CreatedBy,
			@UtcCreatedDate,
			@ModifiedBy,
			@UtcModifiedDate
		)

		COMMIT TRANSACTION

	SET NOCOUNT OFF
END

