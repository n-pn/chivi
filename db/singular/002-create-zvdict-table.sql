CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE IF NOT EXISTS zvdict(
  name citext NOT NULL PRIMARY KEY,
  kind smallint NOT NULL DEFAULT 0,
  d_id int NOT NULL UNIQUE,
  --
  label text NOT NULL DEFAULT '',
  brief text NOT NULL DEFAULT '',
  p_min int NOT NULL DEFAULT 0,
  --
  total int NOT NULL DEFAULT 0,
  users text[] NOT NULL DEFAULT '{}',
  mtime int NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS zvdict_type_idx ON zvdict(kind);

CREATE INDEX IF NOT EXISTS zvdict_time_idx ON zvdict(mtime);
