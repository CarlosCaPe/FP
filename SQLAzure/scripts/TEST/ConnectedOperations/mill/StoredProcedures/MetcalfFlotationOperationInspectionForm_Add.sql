







/******************************************************************  
* PROCEDURE	: [mill].MetcalfFlotationOperationInspectionForm_Add
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 11 Dec 2024
* SAMPLE	: 

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {11 Dec 2024}		{sxavier}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [mill].[MetcalfFlotationOperationInspectionForm_Add] 
(	
	@TransactionId INT,
	@SiteCode VARCHAR(3),
	@TransactionDate DATETIME,
	@RawData VARCHAR(MAX),
	@InspectionTimeId VARCHAR(64),
	@InitialInspections VARCHAR(MAX),
	@MediaSkips VARCHAR(MAX),
	@DripPansCleaned VARCHAR(MAX),
	@CoreMeasurements VARCHAR(MAX),
	@Reagents VARCHAR(MAX),
	@Column1AirSparger VARCHAR(MAX),
	@Column2AirSparger VARCHAR(MAX),
	@Column3AirSparger VARCHAR(MAX),
	@Column4AirSparger VARCHAR(MAX),
	@Column1StaticMixers VARCHAR(MAX),
	@Column2StaticMixers VARCHAR(MAX),
	@Column3StaticMixers VARCHAR(MAX),
	@Column4StaticMixers VARCHAR(MAX),
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

		INSERT INTO mill.MetcalfFlotationOperationInspectionForm
		(	
			TransactionId,
			SiteCode,
			TransactionDate,
			RawData,
			InspectionTimeId,
			InitialInspections,
			MediaSkips,
			DripPansCleaned,
			CoreMeasurements,
			Reagents,
			Column1AirSparger,
			Column2AirSparger,
			Column3AirSparger,
			Column4AirSparger,
			Column1StaticMixers,
			Column2StaticMixers,
			Column3StaticMixers,
			Column4StaticMixers,
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
			@InspectionTimeId,
			@InitialInspections,
			@MediaSkips,
			@DripPansCleaned,
			@CoreMeasurements,
			@Reagents,
			@Column1AirSparger,
			@Column2AirSparger,
			@Column3AirSparger,
			@Column4AirSparger,
			@Column1StaticMixers,
			@Column2StaticMixers,
			@Column3StaticMixers,
			@Column4StaticMixers,
			@InspectionComment,
			@CreatedBy,
			@UtcCreatedDate,
			@ModifiedBy,
			@UtcModifiedDate
		)

		COMMIT TRANSACTION

	SET NOCOUNT OFF
END

