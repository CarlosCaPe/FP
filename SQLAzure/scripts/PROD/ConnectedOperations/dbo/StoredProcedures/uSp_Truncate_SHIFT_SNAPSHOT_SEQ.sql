-- =============================================
-- Author:		David L. Gray
-- Create date: 2025-10-06
-- Description:	Truncate Table as Owner to Speed 
--				Up [dbo].[UPSERT_CONOPS_SHIFT_SNAPSHOT_SEQ] 
-- =============================================
CREATE   PROCEDURE [dbo].[uSp_Truncate_SHIFT_SNAPSHOT_SEQ] 
WITH EXECUTE AS OWNER
AS 
BEGIN
	SET NOCOUNT ON;

	TRUNCATE TABLE [DBO].[SHIFT_SNAPSHOT_SEQ];

END
