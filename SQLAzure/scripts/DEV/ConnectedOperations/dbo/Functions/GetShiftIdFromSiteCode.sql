
-- =============================================
-- Author:		{sxavier}
-- Create date: {03 Oct 2023}
-- Description:	{Get Shift Id}
-- =============================================
CREATE FUNCTION [dbo].[GetShiftIdFromSiteCode]
(
	@SiteCode CHAR(3),
	@ShiftFlag CHAR(4)
)
RETURNS varchar(16)
AS
BEGIN
	IF @SiteCode = 'BAG'
	BEGIN
		RETURN (SELECT ShiftId FROM bag.CONOPS_BAG_SHIFT_INFO_V WHERE SHIFTFLAG = @ShiftFlag)
	END
	ELSE IF @SiteCode = 'CVE'
	BEGIN
		RETURN (SELECT ShiftId FROM cer.CONOPS_CER_SHIFT_INFO_V WHERE SHIFTFLAG = @ShiftFlag)
	END
	ELSE IF @SiteCode = 'CHN'
	BEGIN
		RETURN (SELECT ShiftId FROM chi.CONOPS_CHI_SHIFT_INFO_V WHERE SHIFTFLAG = @ShiftFlag)
	END
	ELSE IF @SiteCode = 'CMX'
	BEGIN
		RETURN (SELECT ShiftId FROM cli.CONOPS_CLI_SHIFT_INFO_V WHERE SHIFTFLAG = @ShiftFlag)
	END
	ELSE IF @SiteCode = 'MOR'
	BEGIN
		RETURN (SELECT ShiftId FROM mor.CONOPS_MOR_SHIFT_INFO_V WHERE SHIFTFLAG = @ShiftFlag)
	END
	ELSE IF @SiteCode = 'SAM'
	BEGIN
		RETURN (SELECT ShiftId FROM saf.CONOPS_SAF_SHIFT_INFO_V WHERE SHIFTFLAG = @ShiftFlag)
	END
	ELSE IF @SiteCode = 'SIE'
	BEGIN
		RETURN (SELECT ShiftId FROM sie.CONOPS_SIE_SHIFT_INFO_V WHERE SHIFTFLAG = @ShiftFlag)
	END
	ELSE IF @SiteCode = 'TYR'
	BEGIN
		RETURN (SELECT ShiftId FROM tyr.CONOPS_TYR_SHIFT_INFO_V WHERE SHIFTFLAG = @ShiftFlag)
	END
	ELSE IF @SiteCode = 'ABR'
	BEGIN
		RETURN (SELECT ShiftId FROM abr.CONOPS_ABR_SHIFT_INFO_V WHERE SHIFTFLAG = @ShiftFlag)
	END

	RETURN NULL

END
