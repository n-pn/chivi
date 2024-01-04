ALTER TABLE authors RENAME COLUMN zname TO au_zh;

ALTER TABLE authors RENAME COLUMN vname TO au_vi;

ALTER TABLE authors
  ADD COLUMN au_hv varchar NOT NULL DEFAULT '';

ALTER TABLE authors
  ADD COLUMN au_en varchar NOT NULL DEFAULT '';

ALTER TABLE authors
  ADD COLUMN vi_uc varchar NOT NULL DEFAULT '';

ALTER TABLE authors
  ADD COLUMN vi_gg varchar NOT NULL DEFAULT '';

ALTER TABLE authors
  ADD COLUMN vi_bd varchar NOT NULL DEFAULT '';

ALTER TABLE authors
  ADD COLUMN vi_ms varchar NOT NULL DEFAULT '';

ALTER TABLE authors
  ADD COLUMN en_uc varchar NOT NULL DEFAULT '';

ALTER TABLE authors
  ADD COLUMN en_ms varchar NOT NULL DEFAULT '';

ALTER TABLE authors
  ADD COLUMN en_dl varchar NOT NULL DEFAULT '';

ALTER TABLE authors
  ADD COLUMN en_bd varchar NOT NULL DEFAULT '';

ALTER TABLE authors
  ADD COLUMN en_gg varchar NOT NULL DEFAULT '';
