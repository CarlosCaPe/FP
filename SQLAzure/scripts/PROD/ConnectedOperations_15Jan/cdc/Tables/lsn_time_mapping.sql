CREATE TABLE [cdc].[lsn_time_mapping] (
    [start_lsn] binary(10) NOT NULL,
    [tran_begin_time] datetime NULL,
    [tran_end_time] datetime NULL,
    [tran_id] varbinary(10) NULL,
    [tran_begin_lsn] binary(10) NULL
);