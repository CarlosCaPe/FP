
	create function cdc.[fn_cdc_get_net_changes_ ... ](
		@from_lns binary(10),
		@to_lsn binary(10),
		@row_filter_options nvarchar(30)
	)
	returns table
	return	
		select 0 as 'col' 