ALTER TABLE btitles RENAME COLUMN name_zh TO bt_zh;

ALTER TABLE btitles RENAME COLUMN name_vi TO bt_vi;

ALTER TABLE btitles RENAME COLUMN name_hv TO bt_hv;

ALTER TABLE btitles RENAME COLUMN name_en TO bt_en;

ALTER TABLE btitles RENAME COLUMN name_mt_v1 TO vi_qt;

ALTER TABLE btitles RENAME COLUMN name_mt_ai TO vi_uc;

ALTER TABLE btitles RENAME COLUMN name_vi_ms TO vi_ms;

ALTER TABLE btitles RENAME COLUMN name_vi_gg TO vi_gg;

ALTER TABLE btitles RENAME COLUMN name_vi_bd TO vi_bd;

ALTER TABLE btitles RENAME COLUMN name_en_ms TO en_ms;

ALTER TABLE btitles RENAME COLUMN name_en_dl TO en_dl;

ALTER TABLE btitles RENAME COLUMN name_en_bd TO en_bd;

ALTER TABLE btitles
  ADD COLUMN en_uc text NOT NULL DEFAULT '';

ALTER TABLE btitles
  ADD COLUMN en_gg text NOT NULL DEFAULT '';
