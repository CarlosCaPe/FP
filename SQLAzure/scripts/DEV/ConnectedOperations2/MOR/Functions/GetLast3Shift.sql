
/******************************************************************  
* FUNCTION	: mor.GetLast3Shift()
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 06 May 2025
* SAMPLE	: 
	1. SELECT mor.GetLast3Shift()
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {06 May 2025}		{ggosal1}		{Initial Created}
*******************************************************************/ 

CREATE FUNCTION mor.GetLast3Shift()
RETURNS INT
AS
BEGIN
	DECLARE @ShiftID INT;

	WITH ShiftOrder AS (
		SELECT 
			SHIFTID,
			DbName,
			ROW_NUMBER() OVER(ORDER BY SHIFTID DESC) AS Rn
		FROM mor.shift_info WITH (NOLOCK)
    )
	SELECT @ShiftID = ShiftID
	FROM ShiftOrder
	WHERE Rn = 3;

	RETURN @ShiftID;
END

