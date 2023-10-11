
ALTER TABLE rmstems
  ADD COLUMN IF NOT EXISTS _btitle_ts_ varchar GENERATED ALWAYS AS (scrub_name(btitle_zh, btitle_vi)) STORED,
  ADD COLUMN IF NOT EXISTS _author_ts_ varchar GENERATED ALWAYS AS (scrub_name(author_zh, author_vi)) STORED;

CREATE INDEX IF NOT EXISTS rmstems_btitle_ts_idx ON rmstems USING GIN(_btitle_ts_ gin_trgm_ops);

CREATE INDEX IF NOT EXISTS rmstems_author_ts_idx ON rmstems USING GIN(_author_ts_ gin_trgm_ops);

drop index if exists rmstems_vauthor_idx;
drop index if exists rmstems_zauthor_idx;
drop index if exists rmstems_vname_idx;
drop index if exists rmstems_zname_idx;
