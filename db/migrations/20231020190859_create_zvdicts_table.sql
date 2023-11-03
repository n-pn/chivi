-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE IF NOT EXISTS zvdicts(
  dname varchar NOT NULL PRIMARY KEY,
  vname varchar NOT NULL DEFAULT '',
  brief text NOT NULL DEFAULT '',
  --
  dtype smallint NOT NULL DEFAULT 0,
  dsize integer NOT NULL DEFAULT 0,
  --
  users text[] NOT NULL DEFAULT '{}',
  mtime integer NOT NULL DEFAULT 0,
  --
  _flag integer NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS zvdicts_dtype_idx ON dicts(dtype);

CREATE INDEX IF NOT EXISTS zvdicts_mtime_idx ON dicts(mtime);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS zvdicts;
