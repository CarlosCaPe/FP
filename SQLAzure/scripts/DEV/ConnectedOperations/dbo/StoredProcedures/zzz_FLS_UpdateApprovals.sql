




/******************************************************************  
* PROCEDURE	: dbo.FLS_UpdateApprovals
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 17 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_UpdateApprovals '08CA9C12-11A3-47C3-A5DD-2F658DA63CF4', '22DBD099-E121-4B35-85BD-94F245DF658E', 
		'F09B90A2-BF48-41D1-B475-4F1CA094712B', 3, 'Roberto', '0000000003', '0000000003', 'Not Approved', 'Running','0000000003'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Apr 2023}		{sxavier}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_UpdateApprovals] 
(	
	@ID VARCHAR(36),
	@ActivityID VARCHAR(36),
	@RequestID VARCHAR(36),
	@SequenceID SMALLINT,
	@ApproverAlias VARCHAR(64),
	@ApproverID CHAR(10),
	@ClosedByID CHAR(10),
	@Comments VARCHAR(MAX),
	@ApplicationStatus VARCHAR(16),
	@ModifiedBy CHAR(10)
)
AS                        
BEGIN    
	
	SET NOCOUNT ON
	
	UPDATE 
		dbo.FLS_Approvals
	SET
		ActivityID = @ActivityID,
		RequestID = @RequestID,
		SequenceID = @SequenceID,
		ApproverAlias = @ApproverAlias,
		ApproverID = @ApproverID,
		ClosedByID = @ClosedByID,
		Comments = @Comments,
		ApplicationStatus = @ApplicationStatus,
		LastModifiedBy = @ModifiedBy,
		UtcLastModifiedDate = GETUTCDATE()
	WHERE
		ID = @ID

	SET NOCOUNT OFF

END

