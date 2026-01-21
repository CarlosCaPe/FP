
	--
	-- Name: [cdc].[sp_batchinsert_lsn_time_mapping]
	--
	-- Description:
	--	Stored procedure used internally to batch populate cdc.lsn_time_mapping table
	--
	-- Parameters: 
	--   @rowcount                     int -- the number of rows to be inserted in the batch, >= 1,and  <= 419
	--	@start_lsn_1                   binary(10)			-- Commit lsn associated with change table entry
	--	@tran_begin_time_1		datetime			-- Transaction begin time of entry
	--	@tran_end_time_1		datetime			-- Transaction end time of entry
	--	@tran_id_1			varbinary(10)		-- Transaction XDES ID
	--   @tran_begin_lsn_1			binary(10)		---- begin lsn of the associated transaction
	--    ...
	--	@start_lsn_419                   binary(10)			-- Commit lsn associated with change table entry
	--	@tran_begin_time_419 	    datetime			-- Transaction begin time of entry
	--	@tran_end_time_419	    datetime			-- Transaction end time of entry
	--	@tran_id_419			    varbinary(10)		-- Transaction XDES ID
	--   @tran_begin_lsn_419			binary(10)		---- begin lsn of the associated transaction
	-- Returns: nothing 
	-- 
	create procedure [cdc].[sp_batchinsert_lsn_time_mapping]  				
	(
	  @rowcount int,
	  @start_lsn_1 binary(10), @tran_begin_time_1 datetime, @tran_end_time_1 datetime, @tran_id_1 varbinary(10), @tran_begin_lsn_1 binary(10),
	  @start_lsn_2 binary(10), @tran_begin_time_2 datetime, @tran_end_time_2 datetime, @tran_id_2 varbinary(10), @tran_begin_lsn_2 binary(10),
	  @start_lsn_3 binary(10), @tran_begin_time_3 datetime, @tran_end_time_3 datetime, @tran_id_3 varbinary(10), @tran_begin_lsn_3 binary(10),
	  @start_lsn_4 binary(10), @tran_begin_time_4 datetime, @tran_end_time_4 datetime, @tran_id_4 varbinary(10), @tran_begin_lsn_4 binary(10),
	  @start_lsn_5 binary(10), @tran_begin_time_5 datetime, @tran_end_time_5 datetime, @tran_id_5 varbinary(10), @tran_begin_lsn_5 binary(10),
	  @start_lsn_6 binary(10), @tran_begin_time_6 datetime, @tran_end_time_6 datetime, @tran_id_6 varbinary(10), @tran_begin_lsn_6 binary(10),
	  @start_lsn_7 binary(10), @tran_begin_time_7 datetime, @tran_end_time_7 datetime, @tran_id_7 varbinary(10), @tran_begin_lsn_7 binary(10),
	  @start_lsn_8 binary(10), @tran_begin_time_8 datetime, @tran_end_time_8 datetime, @tran_id_8 varbinary(10), @tran_begin_lsn_8 binary(10),
	  @start_lsn_9 binary(10), @tran_begin_time_9 datetime, @tran_end_time_9 datetime, @tran_id_9 varbinary(10), @tran_begin_lsn_9 binary(10),
	  @start_lsn_10 binary(10), @tran_begin_time_10 datetime, @tran_end_time_10 datetime, @tran_id_10 varbinary(10), @tran_begin_lsn_10 binary(10),
	  @start_lsn_11 binary(10), @tran_begin_time_11 datetime, @tran_end_time_11 datetime, @tran_id_11 varbinary(10), @tran_begin_lsn_11 binary(10),
	  @start_lsn_12 binary(10), @tran_begin_time_12 datetime, @tran_end_time_12 datetime, @tran_id_12 varbinary(10), @tran_begin_lsn_12 binary(10),
	  @start_lsn_13 binary(10), @tran_begin_time_13 datetime, @tran_end_time_13 datetime, @tran_id_13 varbinary(10), @tran_begin_lsn_13 binary(10),
	  @start_lsn_14 binary(10), @tran_begin_time_14 datetime, @tran_end_time_14 datetime, @tran_id_14 varbinary(10), @tran_begin_lsn_14 binary(10),
	  @start_lsn_15 binary(10), @tran_begin_time_15 datetime, @tran_end_time_15 datetime, @tran_id_15 varbinary(10), @tran_begin_lsn_15 binary(10),
	  @start_lsn_16 binary(10), @tran_begin_time_16 datetime, @tran_end_time_16 datetime, @tran_id_16 varbinary(10), @tran_begin_lsn_16 binary(10),
	  @start_lsn_17 binary(10), @tran_begin_time_17 datetime, @tran_end_time_17 datetime, @tran_id_17 varbinary(10), @tran_begin_lsn_17 binary(10),
	  @start_lsn_18 binary(10), @tran_begin_time_18 datetime, @tran_end_time_18 datetime, @tran_id_18 varbinary(10), @tran_begin_lsn_18 binary(10),
	  @start_lsn_19 binary(10), @tran_begin_time_19 datetime, @tran_end_time_19 datetime, @tran_id_19 varbinary(10), @tran_begin_lsn_19 binary(10),
	  @start_lsn_20 binary(10), @tran_begin_time_20 datetime, @tran_end_time