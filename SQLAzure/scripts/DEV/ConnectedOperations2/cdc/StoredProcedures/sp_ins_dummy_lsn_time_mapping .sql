
	--
	-- Name: [cdc].[sp_ins_dummy_lsn_time_mapping]
	--
	-- Description: append a dummy entry. A dummy entry has 0x0 for the column tran_id
	--
	-- Parameters: 
	--	@lastflushed_lsn		binary(10)			
	--
	-- Returns:	0	success
	--			1   failure 
	-- 
	create procedure [cdc].[sp_ins_dummy_lsn_time_mapping ]
	(
		@lastflushed_lsn binary(10) = 0x0
	)
	as
	begin
		set nocount on
		declare 	@cur_time datetime = GETDATE(),
				@dummy_entry_interval int = 300 --default, in seconds

		if @lastflushed_lsn = 0x0
			return (0)

		--avoid inserting duplicate entries
		if exists(select * from [cdc].[lsn_time_mapping] where start_lsn = @lastflushed_lsn)
			return (0)

		--if the last entry was inserted within the interval, skip this dummy entry
		if exists(select * from [cdc].[lsn_time_mapping] where start_lsn = (select max(start_lsn) from [cdc].[lsn_time_mapping])
													and DATEDIFF(second, tran_end_time,  @cur_time) <= @dummy_entry_interval)
		begin
			return (0)
		end

		insert [cdc].[lsn_time_mapping] values(@lastflushed_lsn, @cur_time, @cur_time, 0x0, 0x0)

		if @@error != 0
			return (1)
		else
			return (0)
	end