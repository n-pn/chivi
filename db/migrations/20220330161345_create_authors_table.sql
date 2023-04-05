-- +micrate Up
CREATE TABLE authors(
  id serial PRIMARY KEY,
  --
  zname text NOT NULL UNIQUE,
  vname text NOT NULL DEFAULT '',
  --
  vdesc text NOT NULL DEFAULT '',
  book_count int NOT NULL DEFAULT 0,
  --
  __fts text GENERATED ALWAYS AS (scrub_name(vname)) STORED,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX author_zname_idx ON authors USING GIN(zname gin_trgm_ops);

CREATE INDEX author_fuzzy_idx ON authors USING GIN(__fts gin_trgm_ops);

-- +micrate Down
DROP TABLE IF EXISTS authors;
