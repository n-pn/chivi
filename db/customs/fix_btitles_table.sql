ALTER TABLE btitles RENAME COLUMN zname TO name_zh;

ALTER TABLE btitles RENAME COLUMN hname TO name_hv;

ALTER TABLE btitles RENAME COLUMN vname TO name_vi;

ALTER TABLE btitles
  ADD COLUMN name_en text NOT NULL DEFAULT '';

ALTER TABLE btitles
  ADD COLUMN name_mt_v1 text NOT NULL DEFAULT '';

ALTER TABLE btitles
  ADD COLUMN name_mt_ai text NOT NULL DEFAULT '';

ALTER TABLE btitles
  ADD COLUMN name_vi_ms text NOT NULL DEFAULT '';

ALTER TABLE btitles
  ADD COLUMN name_vi_gg text NOT NULL DEFAULT '';

ALTER TABLE btitles
  ADD COLUMN name_vi_bd text NOT NULL DEFAULT '';

ALTER TABLE btitles
  ADD COLUMN name_en_ms text NOT NULL DEFAULT '';

ALTER TABLE btitles
  ADD COLUMN name_en_dl text NOT NULL DEFAULT '';

ALTER TABLE btitles
  ADD COLUMN name_en_bd text NOT NULL DEFAULT '';
