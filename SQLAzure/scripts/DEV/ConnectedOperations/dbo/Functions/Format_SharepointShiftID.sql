-- =============================================
-- Author:		{jrodulfa}
-- Create date: {05 Dec 2022}
-- Description:	{Convert sharepoint ShiftID value to Shift Info ShiftID Format}
-- =============================================
CREATE FUNCTION [dbo].Format_SharepointShiftID
(
	@SharepointShiftID nvarchar(15)
)
RETURNS varchar(10)
AS
BEGIN
	RETURN (SELECT Right([Year], 2) + FORMAT([Month], '00') + FORMAT([Day], '00') + FORMAT([ShiftNr], '000')
			FROM
			(
				SELECT CAST(REVERSE(PARSENAME(REPLACE(REVERSE([ShiftDate]), '/', '.'), 1)) AS numeric) AS [Month],
					   CAST(REVERSE(PARSENAME(REPLACE(REVERSE([ShiftDate]), '/', '.'), 2)) AS numeric) AS [Day],
					   REVERSE(PARSENAME(REPLACE(REVERSE([ShiftDate]), '/', '.'), 3)) AS [Year],
					   [ShiftNr]
				FROM (
					SELECT REVERSE(PARSENAME(REPLACE(REVERSE(@SharepointShiftID), '-', '.'), 1)) AS [ShiftDate],
						   CAST(REVERSE(PARSENAME(REPLACE(REVERSE(@SharepointShiftID), '-', '.'), 2)) AS numeric) AS [ShiftNr]
				) [main]
			) [shift])
END
