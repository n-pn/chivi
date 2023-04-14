-- +micrate Up
CREATE TABLE btitles(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  --
  zname text NOT NULL UNIQUE,
  vname text NOT NULL DEFAULT '',
  hname text NOT NULL DEFAULT '',
  --
  __fts varchar GENERATED ALWAYS AS (scrub_name(hname, vname)) STORED,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX btitle_zname_idx ON btitles USING GIN(zname gin_trgm_ops);

CREATE INDEX btitle_fuzzy_idx ON btitles USING GIN(__fts gin_trgm_ops);

-- +micrate Down
DROP TABLE IF EXISTS btitles;
