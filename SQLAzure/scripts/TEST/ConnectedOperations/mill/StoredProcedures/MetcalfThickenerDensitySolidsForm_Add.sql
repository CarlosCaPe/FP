







/******************************************************************  
* PROCEDURE	: [mill].[MetcalfThickenerDensitySolidsForm_Add] 
* PURPOSE	: 
* NOTES		: 
* CREATED	: aarivian, 26 Feb 2025
* SAMPLE	: 

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Feb 2025}		{aarivian}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [mill].[MetcalfThickenerDensitySolidsForm_Add] 
(	
	@TransactionId INT,
	@SiteCode VARCHAR(3),
	@TransactionDate DATETIME,
	@ShiftId VARCHAR(3),
	@RawData VARCHAR(MAX),
	@DensitySolids VARCHAR(MAX),
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

		INSERT INTO [mill].[MetcalfThickenerDensitySolidsForm]
		(	
			TransactionId,
			SiteCode,
			TransactionDate,
			ShiftId,
			RawData,
			DensitySolids,
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
			@DensitySolids,
			@InspectionComment,
			@CreatedBy,
			@UtcCreatedDate,
			@ModifiedBy,
			@UtcModifiedDate
		)

		COMMIT TRANSACTION

	SET NOCOUNT OFF
END

