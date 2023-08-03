ALTER TABLE wninfos
  ADD COLUMN IF NOT EXISTS btitle_zh text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS btitle_vi text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS btitle_hv text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS author_zh text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS author_vi text NOT NULL DEFAULT '';

UPDATE
  wninfos
SET
  btitle_vi =(
    SELECT
      vname
    FROM
      btitles
    WHERE
      btitles.zname = wninfos.btitle_zh
    LIMIT 1);

UPDATE
  wninfos
SET
  btitle_hv =(
    SELECT
      hname
    FROM
      btitles
    WHERE
      btitles.zname = wninfos.btitle_zh
    LIMIT 1);

UPDATE
  wninfos
SET
  author_vi =(
    SELECT
      vname
    FROM
      authors
    WHERE
      authors.zname = wninfos.author_zh
    LIMIT 1);

ALTER TABLE wninfos
  ADD COLUMN IF NOT EXISTS _btitle_ts_ varchar GENERATED ALWAYS AS (scrub_name(btitle_vi, btitle_hv)) STORED,
  ADD COLUMN IF NOT EXISTS _author_ts_ varchar GENERATED ALWAYS AS (scrub_name(author_vi)) STORED;

CREATE INDEX IF NOT EXISTS wninfos_btitle_zh_idx ON wninfos USING GIN(btitle_zh gin_trgm_ops);

CREATE INDEX IF NOT EXISTS wninfos_author_zh_idx ON wninfos USING GIN(author_zh gin_trgm_ops);

CREATE INDEX IF NOT EXISTS wninfos_btitle_ts_idx ON wninfos USING GIN(_btitle_ts_ gin_trgm_ops);

CREATE INDEX IF NOT EXISTS wninfos_author_ts_idx ON wninfos USING GIN(_author_ts_ gin_trgm_ops);

CREATE UNIQUE INDEX IF NOT EXISTS wninfos_uniq_name_idx ON wninfos(author_zh, btitle_zh);

-- ALTER TABLE wninfos
-- drop column if EXISTS btitle_id,
-- drop column if EXISTS author_id;
