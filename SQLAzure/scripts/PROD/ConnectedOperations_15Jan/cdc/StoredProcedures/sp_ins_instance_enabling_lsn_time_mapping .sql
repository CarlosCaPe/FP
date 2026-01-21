
	--
	-- Name: [cdc].[sp_ins_instance_enabling_lsn_time_mapping]
	--
	-- Description:query change_tables for the specified capture instance and insert its start_lsn and create_date 
	--          into lsn_time_mapping
	--
	-- Parameters: 
	--	@changetable_objid		int			
	--
	-- Returns:	0	success
	--			1   failure 
	-- 
	create procedure [cdc].[sp_ins_instance_enabling_lsn_time_mapping ]
	(
		@changetable_objid int
	)
	as
	begin
		set nocount on
		 
	insert [cdc].[lsn_time_mapping] 
		select start_lsn, create_date, create_date, 0x0, 0x0
		from [cdc].[change_tables]
		where object_id = @changetable_objid

		if @@error != 0
			return (1)
		else
			return (0)
	end