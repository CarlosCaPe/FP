
	--
	-- Name: [cdc].[sp_ins_lsn_time_mapping]
	--
	-- Description:
	--	Stored procedure used internally to populate cdc.lsn_time_mapping table
	--
	-- Parameters: 
	--	@start_lsn				binary(10)			-- Commit lsn associated with change table entry
	--	@tran_begin_time		datetime			-- Transaction begin time of entry
	--	@tran_end_time			datetime			-- Transaction end time of entry
	--	@tran_id				varbinary(10)		-- Transaction  XDES ID
	--   @tran_begin_lsn			binary(10)		---- begin lsn of the associated transaction
	-- Returns:		 
	-- 
	create procedure [cdc].[sp_ins_lsn_time_mapping]  				
	(														
		@start_lsn				binary(10),
		@tran_begin_time		datetime,
		@tran_end_time			datetime,
		@tran_id				varbinary(10),
		@tran_begin_lsn				binary(10)
	)														
	as
	begin
		set nocount on		

		insert into cdc.lsn_time_mapping
		values
		(
			@start_lsn
			,@tran_begin_time
			,@tran_end_time
			,@tran_id
			,@tran_begin_lsn
		)
	end												