







/******************************************************************  
* PROCEDURE	: [mill].MetcalfRegrindCycloneForm_Add
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 19 Dec 2024
* SAMPLE	: 

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {19 Dec 2024}		{sxavier}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [mill].[MetcalfRegrindCycloneForm_Add] 
(	
	@TransactionId INT,
	@SiteCode VARCHAR(3),
	@TransactionDate DATETIME,
	@RawData VARCHAR(MAX),
	@RegrindCyclones VARCHAR(MAX),
	@MediaSkips VARCHAR(MAX),
	@Vertimills VARCHAR(MAX),
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

		INSERT INTO mill.MetcalfRegrindCycloneForm
		(	
			TransactionId,
			SiteCode,
			TransactionDate,
			RawData,
			RegrindCyclones,
			MediaSkips,
			Vertimills,
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
			@RegrindCyclones,
			@MediaSkips,
			@Vertimills,
			@InspectionComment,
			@CreatedBy,
			@UtcCreatedDate,
			@ModifiedBy,
			@UtcModifiedDate
		)

		COMMIT TRANSACTION

	SET NOCOUNT OFF
END

