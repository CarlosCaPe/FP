CREATE TABLE [cer].[ZZZ_lh2_enum_b_temp] (
    [enum_id] bigint NOT NULL DEFAULT ((0)),
    [EnumTypeId] bigint NOT NULL DEFAULT ((0)),
    [Idx] int NULL,
    [Description] nvarchar(64) NULL,
    [Abbreviation] nvarchar(32) NULL,
    [Flags] int NOT NULL DEFAULT ((0)),
    [logical_delete_flag] char(1) NOT NULL DEFAULT (''),
    [orig_src_id] int NOT NULL DEFAULT ((0)),
    [site_code] varchar(4) NOT NULL DEFAULT (''),
    [capture_ts_utc] datetimeoffset NOT NULL DEFAULT ('01-jan-0001 00:00:00'),
    [integrate_ts_utc] datetimeoffset NOT NULL DEFAULT ('01-jan-0001 00:00:00')
);