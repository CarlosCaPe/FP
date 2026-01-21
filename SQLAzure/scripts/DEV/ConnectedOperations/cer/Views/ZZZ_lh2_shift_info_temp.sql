CREATE VIEW [cer].[ZZZ_lh2_shift_info_temp] AS

CREATE view [cer].[lh2_shift_info_temp] as
SELECT    
	sr.ShiftId AS ShiftId,
	REPLACE
	(
		STR(s.FieldYear, 2) +    
		STR(m.Idx, 2)+     
		STR(s.FieldDay, 2) +     
		LEFT(LOWER(st.Abbreviation),1),    
		' ', '0'
	) ShiftName, 
	sr.shift_DbName DbName,
	s.FieldYear ShiftYear,
	m.Idx ShiftMonth,    
	s.FieldDay ShiftDay,
	LEFT(LOWER(st.Abbreviation),1) ShiftSuffix,
	st.Description AS FullShiftSuffix,
	s.FieldStart AS ShiftStartSecSinceMidnight,
	DATEDIFF
	(
		ss,     
            '1970-01-01',     
        CONVERT
        (
			datetime,     
			REPLACE
			(
				'20'+ 
				STR(s.FieldYear, 2) +    
				STR(m.Idx, 2)+     
				STR(s.FieldDay, 2),    
				' ', '0'
			)
		) 
	) + s.FieldStart ShiftStartTimestamp,   
	s.FieldUtcstart ShiftStartTimestampUtc,  
	CONVERT
	(
		datetime,
		CONVERT 
		(
			date,
			DATEADD
			(
				ss,     
				s.FieldStart,
				CONVERT
				(
					datetime,     
					REPLACE
					(
						'20'+ 
						STR(s.FieldYear, 2) +    
						STR(m.Idx, 2)+     
						STR(s.FieldDay, 2),    
						' ', '0'
					)
				)
			)
		) 
	) ShiftStartDate,
	DATEADD
	(
		ss,     
		s.FieldStart,
		CONVERT
		(
			datetime,     
			REPLACE
			(
				'20'+ 
				STR(s.FieldYear, 2) +    
				STR(m.Idx, 2)+     
				STR(s.FieldDay, 2),    
				' ', '0'
			)
		) 
	) ShiftStartDateTime,
	REPLACE(STR(s.FieldDay,2),' ', '0') + '-' +
	m.Description + '-' +
	'20' + REPLACE(STR(s.FieldYear, 2),' ', '0') + ' ' +
	st.Description FullShiftName,
	s.FieldHoliday AS [Holiday],    
	c.Description AS [Crew],
	s.FieldTime ShiftDuration,    	
	REPLACE(STR(s.FieldDay,2),' ', '0') + '-' +
	m.Description + '-' +
	REPLACE(STR(s.FieldYear, 2),' ', '0')  ShiftDate,
	s.site_code
FROM [CERReferenceCache].[dbo].lh2_shift_root_date_b AS s with(nolock)   
INNER JOIN [CERReferenceCache].[dbo].lh2_shift_root_b AS sr with(nolock)  
ON 
	sr.shift_root_Id = s.shift_root_date_id
INNER JOIN [CERReferenceCache].[dbo].lh2_enum_b AS m with(nolock) 
ON 
	s.FieldMonth = m.enum_Id
INNER JOIN [CERReferenceCache].[dbo].lh2_enum_b AS st with(nolock) 
ON 
	s.FieldShift = st.enum_Id    
INNER JOIN [CERReferenceCache].[dbo].lh2_enum_b AS c with(nolock) 
ON 
	s.FieldCrew = c.enum_Id
