pragma journal_mode = WAL;

CREATE TABLE IF NOT EXISTS attrs (
  --
  tag integer NOT NULL DEFAULT 0,
  key varchar NOT NULL DEFAULT '',
  --
  invisible boolean NOT NULL DEFAULT 0,
  --
  cap_after boolean NOT NULL DEFAULT 0,
  cap_relay boolean NOT NULL DEFAULT 0,
  --
  no_ws_before boolean NOT NULL DEFAULT 0,
  no_ws_after boolean NOT NULL DEFAULT 0,
  --
  extra text NOT NULL DEFAULT '', -- extra attributes as json text
  --
  mtime int NOT NULL DEFAULT 0,
  PRIMARY KEY (tag, key)
);

CREATE INDEX IF NOT EXISTS attrs_time_idx ON attrs (mtime);