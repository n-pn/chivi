-- +micrate Up
CREATE TABLE btitles (
  id serial PRIMARY KEY,
  --
  zname text NOT NULL UNIQUE,
  vname text NOT NULL DEFAULT '',
  hname text NOT NULL DEFAULT '',
  --
  -- vslug text not null default '',
  -- hslug text not null default '',
  __fts varchar GENERATED ALWAYS AS (scrub_name (hname, vname)) STORED,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX btitle_zname_idx ON btitles USING GIN (zname gin_trgm_ops);

-- CREATE INDEX btitle_vslug_idx ON btitles using GIN (vslug gin_trgm_ops);
-- CREATE INDEX btitle_hslug_idx ON btitles using GIN (hslug gin_trgm_ops);
CREATE INDEX btitle_fuzzy_idx ON btitles USING GIN (__fts gin_trgm_ops);

-- +micrate Down
DROP TABLE IF EXISTS btitles;
